import SwiftUI

//TODO: rename
@available(iOS 16.0, macOS 14, *)
public struct BumpAnimation: ViewModifier {
    let duration: Double
    let scale: Double
    let delay: Double
    @State private var isPulsing = false
    
    public init(duration: Double = 1.5, scale: Double = 1.1, delay: Double = 0.2) {
        self.duration = duration
        self.scale = scale
        self.delay = delay
    }
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? scale : 1.0)
            .animation(
                .linear(duration: duration / 2)
//                .repeatCount(1, autoreverses: true)
                .delay(delay),
                value: isPulsing
            )
            .task {
                isPulsing = true
                try? await Task.sleep(for: .seconds(duration / 2))
                isPulsing = false
            }
    }
}

@available(iOS 16.0, macOS 14, *)
public extension View {
    func bumpAnimation(
        duration: Double = 1.5,
        scale: Double = 1.1,
        delay: Double = 0.2
    ) -> some View {
        modifier(BumpAnimation(duration: duration, scale: scale, delay: delay))
    }
}

@available(iOS 16.0, macOS 14, *)
#Preview {
    RoundedRectangle(cornerRadius: 12)
        .fill(Color.blue)
        .frame(width: 100, height: 100)
        .bumpAnimation(duration: 0.4, scale: 1.2, delay: 0)
}
