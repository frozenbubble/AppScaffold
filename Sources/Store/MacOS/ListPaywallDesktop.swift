import SwiftUI
import SwiftUIX

import RevenueCat
import AppScaffoldUI

#if os(macOS)
// MARK: - Design Constants
private enum PaywallLayout {
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 10
    static let spacing: CGFloat = 12
    static let smallSpacing: CGFloat = 4
    static let productSelectorHeight: CGFloat = 72
    static let featureIconSize: CGFloat = 24
    static let discountTagFontSize: CGFloat = 9
}

private enum PaywallColors {
    static let backgroundOpacity: CGFloat = 0.08
    static let headerBackground = Color(.windowBackgroundColor).opacity(0.8)
    static let itemBackground = Color.secondary.opacity(backgroundOpacity)
}

@available(macOS 14.0, *)
struct ListPaywallDesktop<HeaderContent: View, OtherContent: View>: View {
    // MARK: - Properties
    let features: [FeatureEntry]
    let headerContent: HeaderContent
    let otherContent: OtherContent

    @AppService var purchases: PurchaseService

    @State var availableProducts: [StoreProduct] = []
    @State var selectedProduct: StoreProduct?
    @State var highestPriceProduct: StoreProduct?
    @State var messages = PaywallMessages()

    // MARK: - Initialization
    init(
        features: [FeatureEntry],
        @ViewBuilder headerContent: () -> HeaderContent,
        @ViewBuilder otherContent: () -> OtherContent) {
        self.features = features
        self.headerContent = headerContent()
        self.otherContent = otherContent()
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: PaywallLayout.spacing) {
                    headerView
                    productsView
                    featuresView
                }

                footerLinksView
            }

            bottomBar
        }
        .frame(width: 500, height: 600)
        .background(.secondarySystemBackground)
        .task {
            async let status: () = checkStatus()
            async let products: () = fetchProducts()

            _ = await [status, products]
        }
    }

    // MARK: - UI Components

    private var headerView: some View {
        headerContent
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: PaywallLayout.cornerRadius)
                    .fill(PaywallColors.headerBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: PaywallLayout.cornerRadius))
            .padding(PaywallLayout.padding)
    }

    private var productsView: some View {
        VStack(alignment: .leading, spacing: PaywallLayout.spacing) {
            Text("Pick a plan that suits you")
                .font(.headline)
                .padding(.horizontal, PaywallLayout.padding)

            HStack(spacing: PaywallLayout.spacing) {
                ForEach(purchases.currentOfferingProducts, id: \.productIdentifier) { product in
                    productSelector(product)
                }
            }
            .padding(.horizontal, PaywallLayout.padding)
        }
    }

    private var featuresView: some View {
        VStack(alignment: .leading, spacing: PaywallLayout.spacing) {
            Text("What do you get with Premium?")
                .font(.headline)

            ForEach(features, id: \.name) { feature in
                featureRow(feature)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PaywallLayout.padding)
    }

    private func featureRow(_ feature: FeatureEntry) -> some View {
        HStack(alignment: .center, spacing: PaywallLayout.padding) {
            Image(systemName: feature.icon)
                .resizable()
                .scaledToFit()
                .frame(width: PaywallLayout.featureIconSize, height: PaywallLayout.featureIconSize)
                .foregroundStyle(feature.color.gradient)

            VStack(alignment: .leading, spacing: PaywallLayout.smallSpacing) {
                Text(feature.name)
                    .fontWeight(.medium)
                Text(feature.description)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PaywallLayout.padding)
        .background {
            RoundedRectangle(cornerRadius: PaywallLayout.cornerRadius - 4)
                .fill(PaywallColors.itemBackground)
        }
    }

    private var footerLinksView: some View {
        HStack(spacing: PaywallLayout.spacing) {
            Text("Legal")
                .font(.headline)
            Spacer()
            Button("Privacy") {}
//                .buttonStyle(.link)

//            Text("·")

            Button("Terms") {}
//                .buttonStyle(.link)
        }
        .font(.footnote)
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: PaywallLayout.cornerRadius - 4)
                .fill(PaywallColors.itemBackground)
        }
        .padding(PaywallLayout.padding)
    }

    private var bottomBar: some View {
        HStack {
            Button("Cancel") {}
            Spacer()

            HStack(spacing: PaywallLayout.spacing) {
                Button("Restore") {}
                Button("Start your free 1 week") {}
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(PaywallLayout.padding)
        .background(.secondarySystemBackground)
        .compositingGroup()
        .shadow(color: .primary.opacity(0.1), radius: 2)
    }

    // MARK: - Functions
    func fetchProducts() async {
        do {
            try await purchases.fetchCurrentOfferingProducts()
            availableProducts = purchases.currentOfferingProducts

            highestPriceProduct = purchases.currentOfferingProducts.max(by: { $0.price > $1.price })
            let bestValueProduct = getBestValueProduct(from: purchases.currentOfferingProducts)
            selectedProduct = bestValueProduct
        } catch {
            // Error handling
        }
    }

    /// Returns the product with the lowest monthly price
    /// If products have different subscription periods, prices are normalized to monthly value
    func getBestValueProduct(from products: [StoreProduct]) -> StoreProduct? {
        guard !products.isEmpty else { return nil }

        return products.min { (product1, product2) -> Bool in
            return product1.monthlyPrice < product2.monthlyPrice
        }
    }

    func checkStatus() async {
        await purchases.updateIsUserSubscribedCached(force: true)
    }

    func productSelector(_ product: StoreProduct) -> some View {
        Button {
            withAnimation(.linear(duration: 0.14)) {
                selectedProduct = product
            }
        } label: {
            HStack(alignment: .top, spacing: PaywallLayout.smallSpacing) {
                if product == selectedProduct {
                    Image(systemName: "checkmark.circle.fill")
                        .imageScale(.medium)
                        .foregroundStyle(.blue)
                } else {
                    Image(systemName: "circle")
                        .imageScale(.medium)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: PaywallLayout.smallSpacing) {
                    Text(product.localizedTitle)
                        .fontWeight(.medium)

                    if product.subscriptionPeriod != nil {
                        let text = product.offerPeriodDetails != nil
                            ? messages.priceInfoTrial
                            : messages.priceInfoNormal

                        Text(text.resolvePaywallVariables(with: product))
                            .font(.subheadline)
                    } else {
                        Text("Full access for \(product.localizedPriceString)")
                            .font(.subheadline)
                    }
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(PaywallLayout.smallPadding)
            .frame(height: PaywallLayout.productSelectorHeight, alignment: .top)
            .background {
                RoundedRectangle(cornerRadius: PaywallLayout.cornerRadius).fill(PaywallColors.itemBackground)
            }
            .overlay {
                if let highestPriceProduct {
                    let discount = product.discount(comparedTo: highestPriceProduct)
                    if discount > 0 {
                        discountTag(discount: discount, isSelected: selectedProduct == product)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .contentShape(Rectangle())
    }

    private func discountTag(discount: Decimal, isSelected: Bool) -> some View {
        Text("Save \(discount, format: .percent.precision(.fractionLength(0)))")
            .font(.system(size: PaywallLayout.discountTagFontSize))
            .foregroundColor(.white)
            .padding(.horizontal, PaywallLayout.smallSpacing)
            .padding(.vertical, 3)
            .background(isSelected ? AppScaffoldUI.colors.accent : .secondary)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(6)
    }
}

@available(macOS 14.0, *)
#Preview {
    _ = AppScaffold.useMockPurchases()
    let features: [FeatureEntry] = [
        .init(icon: "star.fill", color: .yellow, name: "Feature 1", description: "Super amazing feature", basic: .missing, pro: .present),
        .init(icon: "person.fill", color: .cyan, name: "Feature 2", description: "Super more amazing feature", basic: .missing, pro: .present)
    ]

    return ListPaywallDesktop(features: features) {
        Text("Header Content")
            .font(.title)
            .foregroundColor(.white)
    } otherContent: {
        Text("Other content here")
    }
}
#endif
