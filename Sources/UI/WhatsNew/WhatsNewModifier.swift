import SwiftUI
import Resolver

@available(iOS 17.0, *)
public extension View {
    /// Shows a "What's New" popup when new features are available
    /// - Parameter exceptWhen: Conditions that prevent the popup from showing
    func showWhatsNew(exceptWhen: Bool = false) -> some View {
        self.modifier(WhatsNewModifier(suppressWhen: exceptWhen))
    }
}

@available(iOS 17.0, *)
struct WhatsNewModifier: ViewModifier {
    @State private var isPresented = false
    private let suppressWhen: Bool
    @Injected private var manager: WhatsNewManager

    init(suppressWhen: Bool) {
        self.suppressWhen = suppressWhen
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                if !suppressWhen && manager.shouldShow() {
                    isPresented = true
                }
            }
            .overlay {
                if isPresented {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .overlay {
                            WhatsNewView(manager: manager)
                        }
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: isPresented)
    }
}

@available(iOS 17.0, *)
#Preview {
    let items = [
        WhatsNewItem(
            title: "New Dashboard",
            description: "Redesigned dashboard with better insights",
            icon: "chart.bar.fill"
        ),
        WhatsNewItem(
            title: "Dark Mode",
            description: "Added support for dark mode",
            icon: "moon.fill"
        )
    ]

    let manager = WhatsNewManager(currentVersion: "1.0.0", items: items)
    Resolver.register { manager as WhatsNewManager }

    return Color.clear
        .showWhatsNew()
        .preferredColorScheme(.dark)
}
