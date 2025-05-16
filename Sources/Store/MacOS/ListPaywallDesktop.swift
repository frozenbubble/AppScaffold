import SwiftUI
import SwiftUIX

import RevenueCat
import AppScaffoldUI

#if os(macOS)
@available(macOS 14.0, *)
struct ListPaywallDesktop<HeaderContent: View, OtherContent: View>: View {
    let features: [FeatureEntry]
    let headerContent: HeaderContent
    let otherContent: OtherContent

    @AppService var purchases: PurchaseService

    @State var availableProducts: [StoreProduct] = []
    @State var selectedProduct: StoreProduct?
    @State var highestPriceProduct: StoreProduct?
    @State var messages = PaywallMessages()

    init(
        features: [FeatureEntry],
        @ViewBuilder headerContent: () -> HeaderContent,
        @ViewBuilder otherContent: () -> OtherContent) {
        self.features = features
        self.headerContent = headerContent()
        self.otherContent = otherContent()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                // Header content with proper visibility
                headerContent
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.windowBackgroundColor).opacity(0.8))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Pick a plan that suits you")
                        .font(.headline)
                        .padding(.horizontal)

                    // Use VStack for product selectors to ensure uniform width
                    HStack(spacing: 12) {
                        ForEach(purchases.currentOfferingProducts, id: \.productIdentifier) { product in
                            productSelector(product)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Features
                VStack(alignment: .leading) {
                    Text("What do you get with Premium?")
                        .font(.headline)
                    
                    ForEach(features, id: \.name) { f in
                        HStack(alignment: .center, spacing: 16) {
                            Image(systemName: f.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(f.color.gradient)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(f.name)
                                    .fontWeight(.medium)
                                Text(f.description)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.1))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

                HStack {
                    Button("Privacy") {
                        
                    }
                    .buttonStyle(.link)
                    
                    Text("·")
                    
                    Button("Terms") {
                        
                    }
                    .buttonStyle(.link)
                }
                .padding()
                // Other content section
//                otherContent
//                    .padding()
            }

            HStack {
                Button("Cancel") {}
                Spacer()

                Button("Restore") {}
                Button("Start your free 1 week") {}
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.secondarySystemBackground)
            .compositingGroup()
            .shadow(color: .primary.opacity(0.1), radius: 2)
        }
        .frame(width: 500, height: 600)
        .background(.secondarySystemBackground)
        .task {
            async let status: () = checkStatus()
            async let products: () = fetchProducts()

            _ = await [status, products]
        }
    }

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
            HStack(alignment: .top, spacing: 4) {
                if product == selectedProduct {
                    Image(systemName: "checkmark.circle.fill")
                        .imageScale(.medium)
                        .foregroundStyle(.blue)
                } else {
                    Image(systemName: "circle")
                        .imageScale(.medium)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.localizedTitle)
                        .fontWeight(.medium)

                    if let subscriptionPeriod = product.subscriptionPeriod {
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
            .padding(10)
            .frame(height: 72, alignment: .top)
            .background {
                RoundedRectangle(cornerRadius: 12).fill(.secondary.opacity(0.2))
            }
//            .overlay{
//                let frameColor = selectedProduct == product ? AppScaffoldUI.colors.accent : Color.secondary
//
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(frameColor, lineWidth: 2)
//            }
            .overlay {
                if let highestPriceProduct {
                    let discount = product.discount(comparedTo: highestPriceProduct)
                    if discount > 0 {
                        Text("Save \(discount, format: .percent.precision(.fractionLength(0)))")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 3)
                            .background(selectedProduct == product ? AppScaffoldUI.colors.accent : .secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(6)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .contentShape(Rectangle())
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
        Text("Header Content 2")
            .font(.title)
            .foregroundColor(.white)
    } otherContent: {
        Text("Other content here")
    }
}
#endif
