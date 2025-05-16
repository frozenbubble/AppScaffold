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

struct SandboxPreview: View {
    @State var isPresented = false
    
    var body: some View {
        VStack {
            Button("Present") { isPresented = true }
        }
        .sheet(isPresented: $isPresented) {
            SandboxView()
        }
    }
}

#Preview {
    SandboxPreview()
        .frame(width: 400, height: 400)
}
