import SwiftUI
import OSLog


@available(iOS 15.0, *)
struct Sandbox: View {
    let logger = Logger(subsystem: "ButterBiscuit.AppScaffold", category: "Sandbox")
    var body: some View {
        VStack {
            Text("Hello, World!")
        }
        .onAppear {
            print("\u{001B}[0;33myellow")

        }
    }
}

@available(iOS 15.0, *)
#Preview {
    Sandbox()
}
