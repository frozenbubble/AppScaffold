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
    let purchaseSuccess: () -> Void
    let restoreSuccess: () -> Void

    public init(purchaseSuccess: @escaping () -> Void = {}, restoreSuccess: @escaping () -> Void = {}) {
        self.purchaseSuccess = purchaseSuccess
        self.restoreSuccess = restoreSuccess
    }
}

@available(iOS 17.0, *)
public struct PaywallFooter: View {
    let messages: PaywallMessages
    let actions: PaywallActions
    let links: PaywallLinks

    @AppService var purchases: PurchaseService

    @State var products: [StoreProduct] = []
    @State var selectedProduct: StoreProduct?
    @State var highestPriceProduct: StoreProduct?
    @State var bestValueProduct: StoreProduct?
    @State var isEligibleForTrial: Bool = false
    @State var displayAllPlans: Bool = false
    @State var displayPrivacyPolicy: Bool = false
    @State var displayUrl: URL?

    public init(messages: PaywallMessages, actions: PaywallActions, links: PaywallLinks = .init()) {
        self.messages = messages
        self.actions = actions
        self.links = links
    }

    public var body: some View {
        VStack {
            if displayAllPlans {
                VStack(spacing: 14) {
                    ForEach(products, id: \.productIdentifier) { productSelector($0) }
                }
                .padding(.bottom, 20)
            } else if !purchases.inProgress {
                priceInfo
            }

            purchaseButton
            
            if let offerPeriod = selectedProduct?.offerPeriod
            {
                reassurance.padding(.top, 4)
            }
            
            bottomLinks.padding(.top)
        }
        .padding()
        .disabled(purchases.inProgress)
        .task {
            products = await purchases.fetchCurrentOfferingProducts() ?? []
            applog.debug("Fetched products: \(products)")
            selectedProduct = products.first
            highestPriceProduct = products.max(by: { $0.price > $1.price })
            bestValueProduct = getBestValueProduct(from: products)
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
            selectedProduct = product
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
                    Text("Full access for just \(product.localizedPriceString)/\(product.subscriptionPeriod?.unit.abbreviatedCode ?? "?")")
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
                        Text("Save \(discount, format: .percent.precision(.fractionLength(0)))%")
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

                _ = await purchases.purchase(product: product)
            }
        } label: {
            ZStack {
                if purchases.inProgress {
                    LoadingIndicator(animation: .circleRunner, size: .small)
                } else if let (period, _, value) = selectedProduct?.offerPeriodDetails {
                    Text("Start your free \(value) \(period)")
                        .shimmering()
                } else {
                    let textColor = AppScaffoldUI.colors.paywallButtonTextColor
                    
                    Text("Continue")
                        .shimmering(
                            animation: .easeInOut(duration:2)
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
                    if purchases.inProgress {
                        Color.secondary
                    } else {
                        LinearGradient(
                            colors: [
                                AppScaffoldUI.colors.accent.darken(by: 0.08),
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
        .font(.title3)
        .foregroundStyle(.primary)
    }

    var priceInfo: some View {
        Group {
            if let (period, _, value) = selectedProduct?.offerPeriodDetails, let product = selectedProduct {
                Text("First \(value) \(period) free, then just \(product.currencyCode ?? "") \(product.formattedPrice)/\(String(describing: product.subscriptionPeriod?.unit ?? .none))")
            } else if let product = selectedProduct {
                Text("Full access for just \(product.localizedPriceString)/\(product.subscriptionPeriod?.unit.abbreviatedCode ?? "?")")
            }
        }
        .font(.title3)
    }

    var reassurance: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.shield")
                .foregroundStyle(.green)
            Text("No payment now.")
        }
        .font(.subheadline)
    }

    var bottomLinks: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(duration: 0.3, bounce: 0.3)) { displayAllPlans.toggle() }
            } label: {
                Text("All plans")
                    .underline()
            }
            Text("·")

            Button {
                Task { await purchases.restorePurchases() }
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
                .presentationDragIndicator(.visible)
        }
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

@available(iOS 17.0, *)
#Preview {
    _ = AppScaffold.useMockPurchases()

    return VStack {
        Spacer()
    }
    .paywallFooter(messages: PaywallMessages(), actions: PaywallActions())
}
