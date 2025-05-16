import SwiftUI

#if os(macOS)
@available(macOS 14.0, *)
struct ListPaywallDesktop<HeaderContent: View, HeadlineContent: View, OtherContent: View>: View {
    @AppService var purchases: PurchaseService
    
    var body: some View {
        ScrollView {
            
        }
    }
}

#Preview {

}
#endif
