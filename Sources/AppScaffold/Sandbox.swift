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
        ZStack {
            if purchaseVM.inProgress {
                ProgressView()
            } else {
                Text("Ready")
            }
        }
        .task {
            await purchaseVM.fetchOfferings()
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    AppScaffold.useLogger()
    AppScaffold.useMockPurchases()
    
    return Sandbox()
}
