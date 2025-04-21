import SwiftUI

import RevenueCat
import SwiftUIX

import AppScaffoldCore
import AppScaffoldPurchases
import AppScaffoldUI

public enum PaywallVariable: String {
    case pricePerPeriod = "{{price_per_period}}"
    case pricePerMonth = "{{price_per_month}}"
    case offerPeriod = "{{offer_period}}"
}

public struct PaywallMessages {
    let callToActionNormal: String = "Continue"
    let callToActionTrial: String = "Start your free trial"
//    let
}

public struct PaywallActions {
    let purchaseSuccess: () -> Void = { }
    let restoreSuccess: () -> Void = { }
}

@available(iOS 17.0, *)
public struct PaywallFooter: View {
    let messages: PaywallMessages
    let actions: PaywallActions

    public init(messages: PaywallMessages, actions: PaywallActions) {
        self.messages = messages
        self.actions = actions
    }

    @AppService var purchases: PurchaseService

    @State var products: [StoreProduct] = []
    @State var selectedProduct: StoreProduct?
    @State var highestPriceProduct: StoreProduct?
    @State var bestValueProduct: StoreProduct?
    @State var isEligibleForTrial: Bool = false
    @State var displayAllPlans: Bool = true

    public var body: some View {
        VStack {
            if displayAllPlans {
                VStack {
                    ForEach(products, id: \.productIdentifier) { productSelector($0) }
                }
                .padding(.bottom, 20)
            }

            priceInfo
            purchaseButton
            reassurance.padding(.top, 4)
            bottomLinks.padding(.top)
        }
        .padding()
        .background {
            VisualEffectBlurView(blurStyle: .systemMaterial)
                .ignoresSafeArea()
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task {
            products = await purchases.fetchCurrentOfferingProducts() ?? []
            print("Fetched products: \(products)")
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
            VStack(alignment: .leading) {
                let currency = product.currencyCode ?? "N/A"
//                let c = product.pri
                let period = product.subscriptionPeriod?.unit ?? .none

                Text(product.localizedTitle)
                Text("\(currency) \(product.price)/\(String(describing: period))")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .overlay{
                let frameColor = selectedProduct == product ? AppScaffoldUI.colors.accent : Color.secondary

                RoundedRectangle(cornerRadius: 12)
                    .stroke(frameColor, lineWidth: 2)
            }
        }
        .foregroundStyle(.primary)
        .contentShape(Rectangle())
    }

    var purchaseButton: some View {
        Button {} label: {
            ZStack {
                if let (period, _, value) = selectedProduct?.offerPeriodDetails {
                    Text("Start your free \(value) \(period)")
                        .shimmering()
                } else {
                    Text("Continue")
                        .shimmering()
                }
            }
            .foregroundStyle(.white)
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(AppScaffoldUI.colors.accent)
            .clipShape(RoundedRectangle(cornerRadius: 12))

        }
        .font(.title3)
        .foregroundStyle(.primary)
    }

    var priceInfo: some View {
        Group {
            if let (period, _, value) = selectedProduct?.offerPeriodDetails {
                Text("First \(value) \(period) free, then just <TODO>/<TODO>")
            } else {
                Text("Full access for just <TODO>/<TODO>")
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
                withAnimation { displayAllPlans.toggle() }
            } label: {
                Text("All plans")
                    .underline()
            }
            Text("·")
            Text("Restore").underline()
            Text("·")
            Text("Terms").underline()
            Text("·")
            Text("Privacy").underline()
        }
        .font(.subheadline)
        .foregroundStyle(.primary)
    }
}

@available(iOS 17.0, *)
#Preview {
    _ = AppScaffold.useMockPurchases()

    return VStack {
        Spacer()
        PaywallFooter(messages: PaywallMessages(), actions: PaywallActions())
    }
}
