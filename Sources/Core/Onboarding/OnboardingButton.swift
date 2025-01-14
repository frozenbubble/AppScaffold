import SwiftUI

//public enum OnboardingConfig {
//    static let backgroundColor = Color.systemGroupedBackground
//    static let overlayColor = Color.secondarySystemGroupedBackground
//    
//    static let welcomeScreenWaitTime = 3.2
//    
//    static let transitionAnimation: Animation = .linear(duration: 0.3)
//}

@available(iOS 16.0, *)
public struct OnboardingButton: View {
    let text: String
    let color1: Color
    let color2: Color
    let animation: Animation?
    let action: () -> Void
    
    public init(_ text: String = "Continue", color1: Color? = nil, color2: Color? = nil, animation: Animation? = nil, action: @escaping () -> Void) {
        self.text = text
        self.animation = animation
        self.action = action
        self.color1 = color1 ?? AppScaffold.accent
        self.color2 = color2 ?? AppScaffold.accent
    }
    
    public var body: some View {
        Button {
            if let animation {
                withAnimation(animation) { action() }
            } else {
                withAnimation { action() }
            }
        } label: {
            Text(text)
                .foregroundStyle(.white)
                .font(.title3)
                .fontWeight(.bold)
                .padding(16)
                .frame(maxWidth: .infinity)
//                .background(AppScaffold.accent)
                .background {
                    LinearGradient(
                        colors: [color1, color2],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

@available(iOS 16.0, *)
#Preview {
    ZStack {
        OnboardingButton(color1: .cyan, color2: .blue) { }
            .padding()
            .shadow(color: .black.opacity(0.15), radius: 4)
    }
}
