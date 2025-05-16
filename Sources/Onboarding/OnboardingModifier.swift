import SwiftUI

import AppScaffoldCore

@available(iOS 17.0, macOS 14.0, *)
public struct OnboardingViewModifier<OnboardingView: View>: ViewModifier {
    var onboardingView: OnboardingView

    public init(@ViewBuilder onboardingView: @escaping () -> OnboardingView) {
        self.onboardingView = onboardingView()
    }

    @AppStorage(AppScaffoldStorageKeys.needsOnboarding) var needsOnboarding = true

    @State var needsOnboardingState = true

    public func body(content: Content) -> some View {
        ZStack {
            if needsOnboardingState {
                onboardingView
            } else {
                content.transition(.opacity)
            }
        }
        .onAppear { needsOnboardingState = needsOnboarding }
        .onChange(of: needsOnboarding) {
            withAnimation {
                needsOnboardingState = needsOnboarding
            }
        }
    }
}

@available(iOS 17.0, macOS 14.0, *)
public extension View {
    func withOnboarding<OnboardingView: View>(@ViewBuilder _ onboardingViewGenerator: @escaping () -> OnboardingView) -> some View {
        modifier(OnboardingViewModifier(onboardingView: onboardingViewGenerator))
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    Color.pink
        .withOnboarding {
            ZStack {
                Color.cyan
                Button("Done") {
                    UserDefaults.standard.set(false, forKey: "needsOnboarding")
                }
            }
        }
}
