import SwiftUI

enum OnboardingConfig {
    static let backgroundColor = Color.systemGroupedBackground
    static let overlayColor = Color.secondarySystemGroupedBackground
    
    static let welcomeScreenWaitTime = 3.2
    
    static let transitionAnimation: Animation = .linear(duration: 0.3)
}

@available(iOS 16.0, *)
struct OnboardingButton: View {
    let text: String
    let action: () -> Void
    
    init(_ text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }
    
    init(action: @escaping () -> Void) {
        self.text = "Continue"
        self.action = action
    }
    
    var body: some View {
        Button {
            withAnimation(OnboardingConfig.transitionAnimation) {
                action()
            }
        } label: {
            Text(text)
                .foregroundStyle(.white)
                .font(.title3)
                .fontWeight(.bold)
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(AppScaffold.accent)
//                .background {
//                    LinearGradient(colors: [.accent, .accent.darken(by: 0.08)], startPoint: .top, endPoint: .bottom)
//                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

@available(iOS 16.0, *)
#Preview {
    ZStack {
        OnboardingButton() { }
            .padding()
            .shadow(color: .black.opacity(0.15), radius: 4)
    }
}
