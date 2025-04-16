import SwiftUI

import AppScaffoldCore
import AppScaffoldUI
import Shimmer

@available(iOS 16.0, *)
public struct OnboardingButton: View {
    let text: String
    let color1: Color
    let color2: Color
    let shimmer: Bool
    let animation: Animation?
    let action: () -> Void

    public init(_ text: String = "Continue", color1: Color? = nil, color2: Color? = nil, shimmer: Bool = false, animation: Animation? = nil, action: @escaping () -> Void) {
        self.text = text
        self.animation = animation
        self.action = action
        self.color1 = color1 ?? AppScaffoldUI.accent
        self.color2 = color2 ?? AppScaffoldUI.accent
        self.shimmer = shimmer
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
                .shimmering(
                    active: shimmer,
                    animation: .easeInOut(duration: 2.0).repeatForever(autoreverses: false),
                    gradient: Gradient(colors: [.white.opacity(0.8), .white, .white.opacity(0.8)]),
                    bandSize: 0.3,
                    mode: .mask
                )
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
        OnboardingButton(color1: .cyan, color2: .blue, shimmer: true) { }
            .padding()
            .shadow(color: .black.opacity(0.15), radius: 4)
    }
}
