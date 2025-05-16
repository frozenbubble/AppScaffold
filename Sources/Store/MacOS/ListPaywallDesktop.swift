import SwiftUI
import SwiftUIX

#if os(macOS)
@available(macOS 14.0, *)
struct ListPaywallDesktop<HeaderContent: View, HeadlineContent: View, OtherContent: View>: View {
    let features: [FeatureEntry]
    let headerContent: HeaderContent
    let headlineContent: HeadlineContent
    let otherContent: OtherContent
    
    @AppService var purchases: PurchaseService
    
    init(
        features: [FeatureEntry],
        @ViewBuilder headerContent: () -> HeaderContent,
        @ViewBuilder headlineContent: () -> HeadlineContent,
        @ViewBuilder otherContent: () -> OtherContent) {
        self.features = features
        self.headerContent = headerContent()
        self.headlineContent = headlineContent()
        self.otherContent = otherContent()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                headerContent
                    .frame(height: 230)
                    .frame(maxWidth: .infinity)
                    .background(.systemGray6)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding()
                
//                VStack {
//                }
//                .padding()
//                .background(.cyan)
            }
            .background(.secondarySystemBackground)
            
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
            .shadow(color: .black.opacity(0.11), radius: 2)
        }
        .frame(width: 500, height: 600)
        .task {
            async let status: () = checkStatus()
            async let products: () = fetchProducts()
            
            _ = await [status, products]
        }
    }
    
    func fetchProducts() async {
//        do {
//            try await purchases.fetchCurrentOfferingProducts()
//            
//            useMetadata()
//            highestPriceProduct = purchases.currentOfferingProducts.max(by: { $0.price > $1.price })
//            bestValueProduct = getBestValueProduct(from: purchases.currentOfferingProducts)
//            selectedProduct = bestValueProduct
//        } catch {
//            applog.error(error)
//            isInfoAlertPresented = true
//            infoAlertTitle = "Error"
//            infoAlertMessage = "Failed to fetch product information. If the issue persists, please reach out to us."
//        }
    }
    
    func checkStatus() async {
        await purchases.updateIsUserSubscribedCached(force: true)
    }
}

@available(macOS 14.0, *)
#Preview {
    _ = AppScaffold.useMockPurchases()
    
    return ListPaywallDesktop(features: []) {
        
    } headlineContent: {
        
    } otherContent: {}
}
#endif
