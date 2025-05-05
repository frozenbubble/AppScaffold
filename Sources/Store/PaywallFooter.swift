import SwiftUI

import RevenueCat
import SwiftUIX
import SwiftfulLoadingIndicators

import AppScaffoldCore
import AppScaffoldPurchases
import AppScaffoldUI

public enum PaywallVariable: String, CaseIterable {
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

@available(iOS 17.0, *)
@Observable
class PaywallMessages {
    var callToActionNormal: String
    var callToActionTrial: String
    var reassurance: String
    var priceInfoNormal: String
    var priceInfoTrial: String

    public init(
        callToActionNormal: String = "Continue",
        callToActionTrial: String = "Start your free {{offer_period}}",
        reassurance: String = "No payment now.",
        priceInfoNormal: String = "Full access for just {{price_per_period}}",
        priceInfoTrial: String = "First {{offer_period}} free, then just {{price_per_period}}"
    ) {
        self.callToActionNormal = callToActionNormal
        self.callToActionTrial = callToActionTrial
        self.reassurance = reassurance
        self.priceInfoNormal = priceInfoNormal
        self.priceInfoTrial = priceInfoTrial
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
    let actions: PaywallActions
    let links: PaywallLinks

    @AppService var purchases: PurchaseService
    
    @State private var initialised: Bool = false

    @State var messages = PaywallMessages()
    @State var selectedProduct: StoreProduct?
    @State var highestPriceProduct: StoreProduct?
    @State var bestValueProduct: StoreProduct?
    @State var isEligibleForTrial: Bool = false
    @State var displayAllPlans: Bool = false
    @State var displayPrivacyPolicy: Bool = false
    @State var displayUrl: URL?
    @State var alwaysDisplayReassurance: Bool = false
    @State var enableButtonTextShimmer: Bool = true

    @State private var isInfoAlertPresented: Bool = false
    @State private var infoAlertTitle: String = ""
    @State private var infoAlertMessage: String = ""
    @State private var postAlertAction: (() -> Void)? = nil

    public init(actions: PaywallActions, links: PaywallLinks = .init()) {
        self.actions = actions
        self.links = links
    }

    public var body: some View {
        ZStack {
            if purchases.isUserSubscribedCached {
                paidUserContent.transition(.blurReplace)
            } else {
                unpaidUserContent.transition(.blurReplace)
            }
        }
        .infoAlert(infoAlertTitle, message: infoAlertMessage, isPresented: $isInfoAlertPresented) {
            postAlertAction?()
            postAlertAction = nil
        }
        .task {
            async let status: () = checkStatus()
            async let products: () = fetchProducts()
            
            _ = await [status, products]
        }
    }
    
    func fetchProducts() async {
        do {
            try await purchases.fetchCurrentOfferingProducts()
            
            useMetadata()
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
    
    func checkStatus() async {
        await purchases.updateIsUserSubscribedCached(force: true)
    }
    
    var unpaidUserContent: some View {
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

            bottomLinks
                .padding(.top)
                .redactedEffect(active: Binding(
                    get: { purchases.checkingStatus || (purchases.fetchingInProgress && purchases.currentOfferingProducts.isEmpty) },
                    set: {_ in}
                ))
        }
        .padding()
        .disabled(purchases.purchaseInProgress || purchases.fetchingInProgress)
    }
    
    var paidUserContent: some View {
        VStack(spacing: 20) {
            Text("You have Premium")
                .font(.title2)
                .fontWeight(.semibold)
            VStack(spacing: 8) {
                Text("You can manage your subscription in")
                Button("Settings") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
                .fontWeight(.semibold)
            }
            Spacer()
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, maxHeight: 200)
    }

    /// Returns the product with the lowest monthly price
    /// If products have different subscription periods, prices are normalized to monthly value
    func getBestValueProduct(from products: [StoreProduct]) -> StoreProduct? {
        guard !products.isEmpty else { return nil }

        return products.min { (product1, product2) -> Bool in
            return product1.monthlyPrice < product2.monthlyPrice
        }
    }

    func useMetadata() {
        guard let currentOffering = purchases.currentOffering  else {
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

        alwaysDisplayReassurance = currentOffering.getMetadataValue(for: "alwaysDisplayReassurance", default: false)
        enableButtonTextShimmer = currentOffering.getMetadataValue(for: "enableButtonTextShimmer", default: true)
    }

    func productSelector(_ product: StoreProduct) -> some View {
        Button {
//            withAnimation {
                selectedProduct = product
//            }
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
                .multilineTextAlignment(.leading)
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
        ZStack {
            if purchases.fetchingInProgress || purchases.checkingStatus {
                Text("Loading...")
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .redactedEffect(active: .constant(true))
            } else {
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
                        if purchases.purchaseInProgress {
                            LoadingIndicator(animation: .circleRunner, size: .small)
                        } else {
                            let buttonText = selectedProduct.map { product in
                                product.offerPeriodDetails != nil
                                    ? messages.callToActionTrial.resolvePaywallVariables(with: product)
                                    : messages.callToActionNormal.resolvePaywallVariables(with: product)
                            } ?? messages.callToActionNormal

                            let animationDuration = Double(buttonText.count) / 4.0

                            Text(buttonText)
                                .fontWeight(.semibold)
                                .transition(.opacity)
                                .shimmering(
                                    active: enableButtonTextShimmer,
                                    animation: .easeInOut(duration: animationDuration)
                                        .delay(2.5)
                                        .repeatForever(autoreverses: false),
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.85), .white, .white.opacity(0.85)])
                                )
                        }
                    }
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background {
                        ZStack {
                            if purchases.purchaseInProgress || purchases.currentOfferingProducts.isEmpty {
                                Color.secondary.opacity(0.5)
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
                }
                .foregroundStyle(.primary)
            }
        }
    }

    var priceInfo: some View {
        Group {
            if let product = selectedProduct {
                let text = product.offerPeriodDetails != nil
                    ? messages.priceInfoTrial
                    : messages.priceInfoNormal
                Text(text.resolvePaywallVariables(with: product))
            } else {
                Text("Fetching Price info")
                    .redactedEffect(active: .constant(true))
            }
        }
    }

    var reassurance: some View {
        ZStack {
            if alwaysDisplayReassurance || selectedProduct?.offerPeriod != nil {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.shield")
                        .foregroundStyle(.green)
                    Text(messages.reassurance)
                }
                .font(.subheadline)
                .transition(.blurReplace)
            } else if purchases.fetchingInProgress || purchases.checkingStatus {
                Text("Loading...")
                    .font(.subheadline)
                    .redactedEffect(active: .constant(true))
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
        postAlertAction = {
            actions.purchaseSuccess(customerInfo)
            Task { await purchases.updateIsUserSubscribedCached(force: true) }
        }
    }

    func purchaseFailure(error: PurchaseError) {
        isInfoAlertPresented = true
        infoAlertTitle = "Purchase failed"
        infoAlertMessage = "An error happened while processing your purchase."
        applog.error("Purchase failed: \(error)")
        postAlertAction = {
            actions.purchaseFailure(error)
            Task { await purchases.updateIsUserSubscribedCached(force: true) }
        }
    }

    func restoreSuccess(_ customerInfo: CustomerInfo) {
        isInfoAlertPresented = true
        infoAlertTitle = "Restore successful"
        infoAlertMessage = "Your purchases have been restored."
        applog.info("Restore successful")
        postAlertAction = {
            actions.restoreSuccess(customerInfo)
            Task { await purchases.updateIsUserSubscribedCached(force: true) }
        }
    }

    func restoreFailure(error: PurchaseError) {
        isInfoAlertPresented = true
        infoAlertTitle = "Restore failed"
        infoAlertMessage = "There was a problem restoring your purchases."
        applog.error("Restore failed: \(error)")
        postAlertAction = {
            actions.restoreFailure(error)
            Task { await purchases.updateIsUserSubscribedCached(force: true) }
        }
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
    .paywallFooter(actions: PaywallActions())
}
