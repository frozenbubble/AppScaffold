import SwiftUI

import RevenueCat
import SwiftUIX

import AppScaffoldCore
import AppScaffoldPurchases
import AppScaffoldUI

@available(iOS 17.0, *)
public struct PaywallFooterModifier: ViewModifier {
    let actions: PaywallActions

    public init(actions: PaywallActions = PaywallActions()) {
        self.actions = actions
    }

    public func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
                .frame(maxHeight: .infinity)

            PaywallFooter(actions: actions)
                .background {
                    VisualEffectBlurView(blurStyle: .systemMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .ignoresSafeArea(edges: .bottom)
                }
        }
    }
}

@available(iOS 17.0, *)
public extension View {
    /// Adds a paywall footer to the bottom of the view
    /// - Parameters:
    ///   - messages: Custom messages to display in the paywall
    ///   - actions: Actions to perform on purchase or restore
    /// - Returns: View with paywall footer attached
    func paywallFooter(
        actions: PaywallActions = PaywallActions()
    ) -> some View {
        self.modifier(PaywallFooterModifier(actions: actions))
    }
}

@available(iOS 17.0, *)
#Preview {
    _ = AppScaffold.useMockPurchases()

    return ScrollView {
        VStack(spacing: 20) {
            ForEach(0..<10) { i in
                Text("Content item \(i)")
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
    }
    .paywallFooter()
}
