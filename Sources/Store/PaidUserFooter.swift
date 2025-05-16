#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import SwiftUI
import SwiftUIX

import RevenueCatUI

@available(iOS 16.0, *)
public struct PaidUserFooterModifier: ViewModifier {
    public func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            VStack(spacing: 20) {
                Text("You already have Premium")
                    .font(.title2)
                    .fontWeight(.semibold)
                VStack(spacing: 8) {
                    Text("You can always manage your subscription in")
                    Button("Settings") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    .fontWeight(.semibold)
                }
                Spacer()
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, maxHeight: 200)
            .background(VisualEffectBlurView(blurStyle: .systemThickMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .ignoresSafeArea(edges: .bottom)
            .offset(CGSize(width: 0.0, height: 50.0))
        }
    }
}

@available(iOS 16.0, *)
public extension View {
    func paidUserFooter() -> some View {
        self.modifier(PaidUserFooterModifier())
    }
}

@available(iOS 16.0, *)
#Preview {
    ZStack {
        Color.systemBackground
    }
    .paidUserFooter()
    .ignoresSafeArea()
}
#endif
