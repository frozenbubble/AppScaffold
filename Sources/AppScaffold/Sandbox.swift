import SwiftUI
import OSLog
import SwiftyBeaver
import Resolver

enum SandboxError: Error {
    case error
}

@available(iOS 17.0, *)
struct Sandbox: View {
    @AppService var purchaseVM: PurchaseService
    
    @State var value1 = 0
    @State var value2 = 0
    
    func dateSg(date: Date) {
        
    }
    
    var body: some View {
//        ListedFeatures.SkewedRoundedRectangle()
        ZStack {
            SkewedRoundedRectangle(cornerRadius: 12)
                .frame(width: 200, height: 50)
            Circle()
                .fill(Color.red)
                .frame(width: 50, height: 50)
        }
        .onChange(of: [value1, value2]) {
            applog.debug("Value1: \(value1), Value2: \(value2)")
        }
        .task {
            try? await Task.sleep(for: .seconds(1))
            value1 = 1
            try? await Task.sleep(for: .seconds(1))
            value2 = 2
            
            dateSg(date: .today)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    AppScaffold.useLogger()
    _ = AppScaffold.useMockPurchases()
    applog.info("asd")
    
    return Sandbox()
}
