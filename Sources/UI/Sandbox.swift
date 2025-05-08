import SwiftUI

private struct SandboxView: View {
    var body: some View {
        VStack {
            Rectangle()
                .fill(
                    .blue.darken(by: 0.2)
                )
            
            Rectangle()
                .fill(
                    .blue.lighten(by: 0.0)
                )
        }
    }
}

#Preview {
    SandboxView()
}
