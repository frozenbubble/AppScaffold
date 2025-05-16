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
                headerContent
                    .frame(height: 230) //TODO: remove
                    .frame(maxWidth: .infinity)
                    .background(.secondarySystemFill)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding()
                
                VStack(alignment: .leading) {
                    Text("Pick a plan that suits you")
                    
                    HStack {
                        ForEach(purchases.currentOfferingProducts, id: \.productIdentifier) { product in
                            productSelector(product)
                        }
                    }
                }

//                VStack {
//                }
//                .padding()
//                .background(.cyan)
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
            
//            useMetadata()
            highestPriceProduct = purchases.currentOfferingProducts.max(by: { $0.price > $1.price })
            let bestValueProduct = getBestValueProduct(from: purchases.currentOfferingProducts)
            selectedProduct = bestValueProduct
        } catch {
//            applog.error(error)
//            isInfoAlertPresented = true
//            infoAlertTitle = "Error"
//            infoAlertMessage = "Failed to fetch product information. If the issue persists, please reach out to us."
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
            HStack(spacing: 12) {
                if product == selectedProduct {
                    Image(systemName: "checkmark.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.blue)
                } else {
                    Image(systemName: "circle")
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading) {
                    Text(product.localizedTitle)
                        .fontWeight(.medium)
                    
                    if let subscriptionPeriod = product.subscriptionPeriod {
                        let text = product.offerPeriodDetails != nil
                            ? messages.priceInfoTrial
                            : messages.priceInfoNormal
                        
                        Text(text.resolvePaywallVariables(with: product))
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
}

@available(macOS 14.0, *)
#Preview {
    _ = AppScaffold.useMockPurchases()

    return ListPaywallDesktop(features: []) {

    } otherContent: {}
}
#endif
