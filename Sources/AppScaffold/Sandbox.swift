import SwiftUI
import OSLog
import SwiftyBeaver

enum SandboxError: Error {
    case error
}

@available(iOS 15.0, *)
struct Sandbox: View {
//    let logger = Logger(subsystem: "ButterBiscuit.AppScaffold", category: "Sandbox")
    var body: some View {
        VStack {
            Text("Hello, World!")
        }
        .onAppear {
//            try! err()
//            Log.warning("asd")
        }
    }
    
    func err() throws {
        throw SandboxError.error
    }
}

@available(iOS 15.0, *)
#Preview {
    return Sandbox()
}
