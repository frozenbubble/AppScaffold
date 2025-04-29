import SwiftUI

import RevenueCat
import SwiftUIX
import SwiftfulLoadingIndicators

import AppScaffoldCore
import AppScaffoldPurchases
import AppScaffoldUI

public enum PaywallVariable: String {
    case pricePerPeriod = "{{price_per_period}}"
    case pricePerMonth = "{{price_per_month}}"
    case offerPeriod = "{{offer_period}}"
}

public struct PaywallLinks {
    let privacyPolicy: URL?
    let termsOfService: URL?

    public init(privacyPolicy: URL? = nil, termsOfService: URL? = nil) {
        self.privacyPolicy = privacyPolicy
        self.termsOfService = termsOfService
    }
}

public struct PaywallMessages {
    let callToActionNormal: String
    let callToActionTrial: String

    public init(callToActionNormal: String = "Continue", callToActionTrial: String = "Start your free trial") {
        self.callToActionNormal = callToActionNormal
        self.callToActionTrial = callToActionTrial
    }
}

public struct PaywallActions {
    let purchaseSuccess: (CustomerInfo) -> Void
    let restoreSuccess: (CustomerInfo) -> Void
    let purchaseFailure: (PurchaseError) -> Void
    let restoreFailure: (PurchaseError) -> Void

    public init(
        purchaseSuccess: @escaping (CustomerInfo) -> Void = { _ in },
        purchaseFailure: @escaping (PurchaseError) -> Void = { _ in },
        restoreSuccess: @escaping (CustomerInfo) -> Void = { _ in },
        restoreFailure: @escaping (PurchaseError) -> Void = { _ in }
    ) {
        self.purchaseSuccess = purchaseSuccess
        self.purchaseFailure = purchaseFailure
        self.restoreSuccess = restoreSuccess
        self.restoreFailure = restoreFailure
    }
}

@available(iOS 17.0, *)
public struct PaywallFooter: View {
    let messages: PaywallMessages
    let actions: PaywallActions
    let links: PaywallLinks

    @AppService var purchases: PurchaseService

    @State var selectedProduct: StoreProduct?
    @State var highestPriceProduct: StoreProduct?
    @State var bestValueProduct: StoreProduct?
    @State var isEligibleForTrial: Bool = false
    @State var displayAllPlans: Bool = false
    @State var displayPrivacyPolicy: Bool = false
    @State var displayUrl: URL?

    @State private var isInfoAlertPresented: Bool = false
    @State private var infoAlertTitle: String = ""
    @State private var infoAlertMessage: String = ""
    @State private var postAlertAction: (() -> Void)? = nil

    public init(messages: PaywallMessages, actions: PaywallActions, links: PaywallLinks = .init()) {
        self.messages = messages
        self.actions = actions
        self.links = links
    }

    public var body: some View {
        VStack {
            if displayAllPlans {
                VStack(spacing: 14) {
                    ForEach(purchases.currentOfferingProducts, id: \.productIdentifier) {
                        productSelector($0)
                    }
                }
                .padding(.bottom, 20)
                .transition(.blurReplace)
            } else {
                priceInfo.transition(.blurReplace)
            }

            purchaseButton

            reassurance.padding(.top, 4)

            bottomLinks.padding(.top)
        }
        .redactedEffect(active: Binding(
            get: { purchases.inProgress && purchases.currentOfferingProducts.isEmpty },
            set: {_ in}
        ))
        .padding()
        .disabled(purchases.inProgress)
        .infoAlert(infoAlertTitle, message: infoAlertMessage, isPresented: $isInfoAlertPresented) {
            postAlertAction?()
            postAlertAction = nil
        }
        .task {
            do {
                try await purchases.fetchCurrentOfferingProducts()
                highestPriceProduct = purchases.currentOfferingProducts.max(by: { $0.price > $1.price })
                bestValueProduct = getBestValueProduct(from: purchases.currentOfferingProducts)
                selectedProduct = bestValueProduct
            } catch {
                applog.error(error)
                isInfoAlertPresented = true
                infoAlertTitle = "Error"
                infoAlertMessage = "Failed to fetch product information. If the issue persists, please reach out to us."
            }
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

    func productSelector(_ product: StoreProduct) -> some View {
        Button {
            withAnimation {
                selectedProduct = product
            }
        } label: {
            HStack(spacing: 12) {
                if product == selectedProduct {
                    Image(systemName: "checkmark.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(AppScaffoldUI.accent)
                } else {
                    Image(systemName: "circle")
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading) {
                    Text(product.localizedTitle)
                        .fontWeight(.medium)
                    if let subscriptionPeriod = product.subscriptionPeriod {
                        Text("Full access for just \(product.localizedPriceString)/\(subscriptionPeriod.unit.abbreviatedCode)")
                    } else {
                        Text("Full access for \(product.localizedPriceString)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .overlay{
                let frameColor = selectedProduct == product ? AppScaffoldUI.colors.accent : Color.secondary

                RoundedRectangle(cornerRadius: 12)
                    .stroke(frameColor, lineWidth: 2)
            }
            .overlay {
                if let highestPriceProduct {
                    let discount = product.discount(comparedTo: highestPriceProduct)
                    if discount > 0 {
                        Text("Save \(discount, format: .percent.precision(.fractionLength(0)))")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(selectedProduct == product ? AppScaffoldUI.colors.accent : .secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(4)
                    }
                }
            }
        }
        .foregroundStyle(.primary)
        .contentShape(Rectangle())
    }

    var purchaseButton: some View {
        Button {
            Task {
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
        } label: {
            ZStack {
                if purchases.inProgress {
                    LoadingIndicator(animation: .circleRunner, size: .small)
                } else {
                    let details = selectedProduct?.offerPeriodDetails
                    let defaultButtonText: String? = purchases.currentOffering?.getMetadataValue(for: "buttonText")
                    
                    let buttonText = defaultButtonText ?? details.map { "Start your free \($0.value) \($0.period)" } ?? "Continue"

                    let animationDuration = Double(buttonText.count) / 4.0

                    Text(buttonText)
                        .fontWeight(.medium)
                        .shimmering(
                            animation: .easeInOut(duration: animationDuration)
                                .delay(2.5)
                                .repeatForever(autoreverses: false),
                            gradient: Gradient(colors: [
                                .white.opacity(0.8), .white, .white.opacity(0.8)])
                        )
                }
            }
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(12)
            .frame(maxWidth: .infinity)
            .background {
                ZStack {
                    if purchases.inProgress || purchases.currentOfferingProducts.isEmpty {
                        Color.secondary
                    } else {
                        LinearGradient(
                            colors: [
                                AppScaffoldUI.colors.accent.darken(by: 0.05),
                                AppScaffoldUI.colors.accent
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shimmering(active: purchases.inProgress)

        }
//        .font(.headline)
        .foregroundStyle(.primary)
    }

    var priceInfo: some View {
        Group {
            if let (period, _, value) = selectedProduct?.offerPeriodDetails, let product = selectedProduct {
                Text("First \(value) \(period) free, then just \(product.pricePerPeriodString)")
            } else if let product = selectedProduct {
                Text("Full access for just \(product.pricePerPeriodString)")
            } else {
                Text("Fetching Price info")
            }
        }
    }

    var reassurance: some View {
        ZStack {
            if (selectedProduct?.offerPeriod) != nil {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.shield")
                        .foregroundStyle(.green)
                    Text("No payment now.")
                }
                .font(.subheadline)
                .transition(.blurReplace)
            } else if purchases.inProgress {
                Text("Loading...")
                    .font(.subheadline)
                    .transition(.blurReplace)
            }
        }
    }

    var bottomLinks: some View {
        HStack(spacing: 12) {
            if purchases.currentOfferingProducts.count > 1 {
                Button {
                    withAnimation(.spring(duration: 0.3, bounce: 0.3)) { displayAllPlans.toggle() }
                } label: {
                    Text("All plans")
                        .underline()
                }
                Text("·")
            }

            Button {
                Task {
                    do throws (PurchaseError) {
                        let customerInfo = try await purchases.restorePurchases()
                        restoreSuccess(customerInfo)
                    } catch {
                        applog.error(error)
                        restoreFailure(error: error)
                    }
                }
            } label: {
                Text("Restore").underline()
            }

            Text("·")

            Button {
                displayUrl = links.termsOfService ??  URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
            } label: {
                Text("Terms").underline()
            }

            Text("·")

            Button {
                if let privacyURL = links.privacyPolicy {
                    displayUrl = privacyURL
                } else {
                    withAnimation { displayPrivacyPolicy.toggle() }
                }
            } label: {
                Text("Privacy").underline()
            }
        }
        .font(.subheadline)
        .foregroundStyle(.primary)
        .sheet(item: $displayUrl) { url in
            LoadingWebView(url: url)
                .ignoresSafeArea(edges: .bottom)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $displayPrivacyPolicy) {
            PrivacyPolicyView()
                .padding(.top)
                .presentationDragIndicator(.visible)
        }
    }

    func purchaseSuccess(_ customerInfo: CustomerInfo) {
        isInfoAlertPresented = true
        infoAlertTitle = "Purchase successful"
        infoAlertMessage = "You're all set."
        applog.info("Purchase successful")
        postAlertAction = { actions.purchaseSuccess(customerInfo) }
    }

    func purchaseFailure(error: PurchaseError) {
        isInfoAlertPresented = true
        infoAlertTitle = "Purchase failed"
        infoAlertMessage = "You're all set."
        applog.error("Purchase failed: \(error)")
        postAlertAction = { actions.purchaseFailure(error) }
    }

    func restoreSuccess(_ customerInfo: CustomerInfo) {
        isInfoAlertPresented = true
        infoAlertTitle = "Restore successful"
        infoAlertMessage = "Your purchases have been restored."
        applog.info("Restore successful")
        postAlertAction = { actions.restoreSuccess(customerInfo) }
    }

    func restoreFailure(error: PurchaseError) {
        isInfoAlertPresented = true
        infoAlertTitle = "Restore failed"
        infoAlertMessage = "There was a problem restoring your purchases."
        applog.error("Restore failed: \(error)")
        postAlertAction = { actions.restoreFailure(error) }
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

@available(iOS 17.0, *)
#Preview {
    AppScaffold.useConsoleLogger(minLevel: .verbose, logPrintWay: .print)
    _ = AppScaffold.useMockPurchases()

    return VStack {
        Spacer()
    }
    .paywallFooter(messages: PaywallMessages(), actions: PaywallActions())
}
