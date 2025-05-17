import SwiftUI
import SwiftUIX

import RevenueCat
import AppScaffoldUI
import AppScaffoldCore
import AppScaffoldPurchases

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
    let actions: PaywallActions
    let links: PaywallLinks

    @AppService var purchases: PurchaseService

    @State var availableProducts: [StoreProduct] = []
    @State var selectedProduct: StoreProduct?
    @State var highestPriceProduct: StoreProduct?
    @State var messages = PaywallMessages()

    @State private var isInfoAlertPresented: Bool = false
    @State private var infoAlertTitle: String = ""
    @State private var infoAlertMessage: String = ""
    @State private var postAlertAction: (() -> Void)? = nil

    // MARK: - Initialization
    init(
        features: [FeatureEntry],
        actions: PaywallActions = PaywallActions(),
        links: PaywallLinks = PaywallLinks(),
        @ViewBuilder headerContent: () -> HeaderContent,
        @ViewBuilder otherContent: () -> OtherContent) {
            self.features = features
            self.actions = actions
            self.links = links
            self.headerContent = headerContent()
            self.otherContent = otherContent()
        }

    private var isLoading: Bool {
        purchases.checkingStatus || purchases.fetchingInProgress
    }

    private var isProductsEmpty: Bool {
        purchases.currentOfferingProducts.isEmpty
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

                //Bottom bar placeholder
                Rectangle()
                    .fill(.clear)
                    .frame(height: 68)
            }

            bottomBar
        }
        .frame(width: 500, height: 600)
        .background(.secondarySystemBackground)
        .alert(infoAlertTitle, isPresented: $isInfoAlertPresented) {
            Button("OK") {
                postAlertAction?()
                postAlertAction = nil
            }
        } message: {
            Text(infoAlertMessage)
        }
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
            .frame(height: 140)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: PaywallLayout.cornerRadius)
                    .fill(PaywallColors.itemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: PaywallLayout.cornerRadius))
            .padding(PaywallLayout.padding)
    }

    private var productsView: some View {
        VStack(alignment: .leading, spacing: PaywallLayout.spacing) {
            Text("Pick a plan that suits you")
                .font(.headline)
                .padding(.horizontal, PaywallLayout.padding)

            if isLoading || isProductsEmpty {
                HStack(spacing: PaywallLayout.spacing) {
                    ForEach(0..<2, id: \.self) { _ in
                        placeholderProductSelector
                    }
                }
                .padding(.horizontal, PaywallLayout.padding)
            } else {
                HStack(spacing: PaywallLayout.spacing) {
                    ForEach(purchases.currentOfferingProducts, id: \.productIdentifier) { product in
                        productSelector(product)
                    }
                }
                .padding(.horizontal, PaywallLayout.padding)
            }
        }
    }

    private var placeholderProductSelector: some View {
        HStack(alignment: .top, spacing: PaywallLayout.smallSpacing) {
            Image(systemName: "circle")
                .imageScale(.medium)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: PaywallLayout.smallSpacing) {
                Text("Product Name")
                    .fontWeight(.medium)
                Text("Product details and pricing information")
                    .font(.subheadline)
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(PaywallLayout.smallPadding)
        .frame(height: PaywallLayout.productSelectorHeight, alignment: .top)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: PaywallLayout.cornerRadius)
                .fill(PaywallColors.itemBackground)
        }
        .redacted(reason: .placeholder)
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

            Button("Privacy") {
                if let privacyURL = links.privacyPolicy {
                    openURL(privacyURL)
                }
            }
            .disabled(links.privacyPolicy == nil || isLoading)

            Button("Terms") {
                if let termsURL = links.termsOfService {
                    openURL(termsURL)
                } else {
                    openURL(URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                }
            }
            .disabled(isLoading)
        }
        .font(.footnote)
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: PaywallLayout.cornerRadius - 4)
                .fill(PaywallColors.itemBackground)
        }
        .padding(.horizontal, PaywallLayout.padding)
        .redacted(reason: isLoading ? .placeholder : [])
    }

    private var bottomBar: some View {
        HStack {
            Button("Cancel") {}
            Spacer()

            HStack(spacing: PaywallLayout.spacing) {
                if isLoading {
                    HStack(spacing: PaywallLayout.spacing) {
                        Text("Restore")
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)

                        Text("Loading...")
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.secondary.opacity(0.7))
                            }
                    }
                    .redacted(reason: .placeholder)
                } else {
                    Button("Restore") {
                        Task {
                            await handleRestore()
                        }
                    }
                    .disabled(purchases.purchaseInProgress)

                    Button(purchaseButtonText) {
                        Task {
                            await handlePurchase()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(purchases.purchaseInProgress ||
                              selectedProduct == nil)
                }
            }
        }
        .padding(PaywallLayout.padding)
        .background(.secondarySystemBackground)
        .compositingGroup()
        .shadow(color: .primary.opacity(0.1), radius: 2)
    }

    private var purchaseButtonText: String {
        guard let product = selectedProduct else {
            return "Subscribe"
        }

        return product.offerPeriodDetails != nil
        ? messages.callToActionTrial.resolvePaywallVariables(with: product)
        : messages.callToActionNormal.resolvePaywallVariables(with: product)
    }

    // MARK: - Functions
    func fetchProducts() async {
        do {
            try await purchases.fetchCurrentOfferingProducts()
            availableProducts = purchases.currentOfferingProducts

            highestPriceProduct = purchases.currentOfferingProducts.max(by: { $0.price > $1.price })
            let bestValueProduct = getBestValueProduct(from: purchases.currentOfferingProducts)
            selectedProduct = bestValueProduct

            useMetadata()
        } catch {
            applog.error(error)
            showAlert(
                title: "Error",
                message: "Failed to fetch product information. If the issue persists, please reach out to us."
            )
        }
    }

    func useMetadata() {
        guard let currentOffering = purchases.currentOffering else {
            return
        }

        let callToActionNormal: String? = currentOffering.getMetadataValue(for: "callToActionNormal", default: nil)
        let callToActionTrial: String? = currentOffering.getMetadataValue(for: "callToActionTrial", default: nil)
        let priceInfoNormal: String? = currentOffering.getMetadataValue(for: "priceInfoNormal", default: nil)
        let priceInfoTrial: String? = currentOffering.getMetadataValue(for: "priceInfoTrial", default: nil)
        let reassurance: String? = currentOffering.getMetadataValue(for: "reassurance", default: nil)

        if let callToActionNormal { messages.callToActionNormal = callToActionNormal }
        if let callToActionTrial { messages.callToActionTrial = callToActionTrial }
        if let priceInfoNormal { messages.priceInfoNormal = priceInfoNormal }
        if let priceInfoTrial { messages.priceInfoTrial = priceInfoTrial }
        if let reassurance { messages.reassurance = reassurance }
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

    func handlePurchase() async {
        guard let product = selectedProduct else {
            return
        }

        do throws(PurchaseError) {
            let customerInfo = try await purchases.purchase(product: product)
            purchaseSuccess(customerInfo)
        } catch {
            applog.error(error)
            purchaseFailure(error: error)
        }
    }

    func handleRestore() async {
        do throws(PurchaseError) {
            let customerInfo = try await purchases.restorePurchases()
            restoreSuccess(customerInfo)
        } catch {
            applog.error(error)
            restoreFailure(error: error)
        }
    }

    func showAlert(title: String, message: String, action: (() -> Void)? = nil) {
        isInfoAlertPresented = true
        infoAlertTitle = title
        infoAlertMessage = message
        postAlertAction = action
    }

    func purchaseSuccess(_ customerInfo: CustomerInfo?) {
        showAlert(
            title: "Purchase successful",
            message: "You're all set.",
            action: { actions.purchaseSuccess(customerInfo) }
        )
        applog.info("Purchase successful")
    }

    func purchaseFailure(error: PurchaseError) {
        showAlert(
            title: "Purchase failed",
            message: "An error happened while processing your purchase.",
            action: { actions.purchaseFailure(error) }
        )
        applog.error("Purchase failed: \(error)")
    }

    func restoreSuccess(_ customerInfo: CustomerInfo?) {
        showAlert(
            title: "Restore successful",
            message: "Your purchases have been restored.",
            action: { actions.restoreSuccess(customerInfo) }
        )
        applog.info("Restore successful")
    }

    func restoreFailure(error: PurchaseError) {
        showAlert(
            title: "Restore failed",
            message: "There was a problem restoring your purchases.",
            action: { actions.restoreFailure(error) }
        )
        applog.error("Restore failed: \(error)")
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

    private func openURL(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
}

@available(macOS 14.0, *)
#Preview {
    _ = AppScaffold.useMockPurchases()
    let features: [FeatureEntry] = [
        .init(icon: "star.fill", color: .yellow, name: "Feature 1", description: "Super amazing feature", basic: .missing, pro: .present),
        .init(icon: "person.fill", color: .cyan, name: "Feature 2", description: "Super more amazing feature", basic: .missing, pro: .present)
    ]

    return ListPaywallDesktop(
        features: features,
        actions: PaywallActions(),
        links: PaywallLinks(
            privacyPolicy: URL(string: "https://www.example.com/privacy"),
            termsOfService: URL(string: "https://www.example.com/terms")
        )
    ) {
        Text("Header Content")
            .font(.title)
            .foregroundColor(.white)
    } otherContent: {
        Text("Other content here")
    }
}
#endif
