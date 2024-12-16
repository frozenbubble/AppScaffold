//import SwiftUI
//import RevenueCatUI
//
//@available(iOS 15.0, *)
//public struct FullScreenPaywall: View {
//    var offering: String? = nil
//    var onFinish: (() -> Void)? = nil
//    
//    @Environment(\.dismiss) var dismiss
//    
//    public var body: some View {
//        ZStack(alignment: .topLeading) {
//            Paywall(offering: offering, onFinish: onFinish)
//            Button {
//               dismiss()
//            } label: {
//                Image(systemName: "xmark.circle")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 26, height: 30)
////                Text("Maybe Later")
////                    .font(.subheadline)
////                    .fontWeight(.medium)
////                    .foregroundStyle(.secondary)
//            }
////            .foregroundStyle(.primary)
//            .foregroundStyle(Color(.systemGray).opacity(0.65))//.opacity(0.88))
//            .padding(.horizontal, 6)
//            .padding(.top, 44)
//            .ignoresSafeArea(.all)
//        }
//    }
//}
//
//@available(iOS 15.0, *)
//extension View {
//    func fullScreenPaywall(
//        isPresented: Binding<Bool>,
//        offering: String? = nil,
//        onFinish: (() -> Void)? = nil
//    ) -> some View {
//        self.fullScreenCover(isPresented: isPresented) {
//            FullScreenPaywall(offering: offering) {
//                onFinish?()
//            }
//        }
//    }
//}
//
//@available(iOS 15.0, *)
//fileprivate struct FullScreenPaywallPreview: View {
//    @State private var isPresented = true
//
//    var body: some View {
//        Button("Present!") {
//            isPresented.toggle()
//        }
//        .fullScreenPaywall(isPresented: $isPresented)
//    }
//}
//
//@available(iOS 15.0, *)
//#Preview {
//    FullScreenPaywallPreview()
//}
