import SwiftUI

@available(iOS 15.0, *)
public struct ShakeEffect: ViewModifier {
    @Binding var trigger: Bool
    var duration: Double = 0.5
    var amount: CGFloat = 10
    
    public func body(content: Content) -> some View {
        content
            .modifier(ShakeAnimation(animatableData: trigger ? 1 : 0, amount: amount))
            .onChange(of: trigger) { newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        trigger = false
                    }
                }
            }
    }
}

// The actual animation geometry effect
@available(iOS 15.0, *)
private struct ShakeAnimation: GeometryEffect {
    var animatableData: CGFloat
    var amount: CGFloat
    
    init(animatableData: CGFloat, amount: CGFloat) {
        self.animatableData = animatableData
        self.amount = amount
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * 4)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// Convenience extension
@available(iOS 15.0, *)
public extension View {
    func shakeEffect(
        play trigger: Binding<Bool>,
        duration: Double = 0.5,
        amount: CGFloat = 10
    ) -> some View {
        modifier(ShakeEffect(trigger: trigger, duration: duration, amount: amount))
    }
}

fileprivate struct ShakePreview: View {
    @State private var shake = true
    @State private var text = ""
    
    var body: some View {
        VStack {
            TextField("Placeholder", text: $text)
                .shakeEffect(play: $shake)
                .padding()
                .background(Color.systemGray5)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .compositingGroup()
                .shadow(color: .black.opacity(0.15), radius: 10)
                .padding()
            
            Button("Test") {
                if text.isEmpty {
                    shake = true
                }
            }
        }
    }
}

@available(iOS 15.0, *)
#Preview {
    ShakePreview()
}
