//import SwiftUI
//
//struct VisualEffectView: NSViewRepresentable {
//    func makeNSView(context: Context) -> NSVisualEffectView {
//        let effectView = NSVisualEffectView()
//        effectView.state = .active
//        return effectView
//    }
//    
//    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
//}
//
//private struct SandboxView: View {
//    var body: some View {
//        VStack {
//            Rectangle()
//                .fill(
//                    .blue
//                )
//            
//            Rectangle()
//                .fill(
//                    .blue
//                )
//        }
//    }
//}
//
//struct SandboxPreview: View {
//    @State var isPresented = false
//    
//    var body: some View {
//        ZStack {
//            Image(systemName: "person")
//                .resizable()
//                .scaledToFit()
//            Rectangle()
//                .fill(.clear)
//                .background(VisualEffectView().ignoresSafeArea())
//        }
//    }
//}
//
//#Preview {
//    SandboxPreview()
//        .frame(width: 400, height: 400)
//}
