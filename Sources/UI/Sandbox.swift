import SwiftUI

private struct SandboxView: View {
    var body: some View {
        VStack {
            Rectangle()
                .fill(
                    .blue
                )
            
            Rectangle()
                .fill(
                    .blue
                )
        }
    }
}

#Preview {
    SandboxView()
}
