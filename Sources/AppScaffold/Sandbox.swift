import SwiftUI
import OSLog
import SwiftyBeaver
import Resolver

enum SandboxError: Error {
    case error
}

@available(iOS 17.0, *)
struct Sandbox: View {
    @SafeInjected var purchaseVM: PurchaseService
    
    var body: some View {
//        ListedFeatures.SkewedRoundedRectangle()
        ZStack {
            SkewedRoundedRectangle(cornerRadius: 12)
                .frame(width: 200, height: 50)
            Circle()
                .fill(Color.red)
                .frame(width: 50, height: 50)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    AppScaffold.useLogger()
    _ = AppScaffold.useMockPurchases()
    
    return Sandbox()
}
