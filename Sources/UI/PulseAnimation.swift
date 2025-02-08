import SwiftUI

@available(iOS 15.0, *)
public struct PulseAnimation: ViewModifier {
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
                .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

@available(iOS 15.0, *)
public extension View {
    func pulseAnimation(
        duration: Double = 1.5,
        scale: Double = 1.1,
        delay: Double = 0.2
    ) -> some View {
        modifier(PulseAnimation(duration: duration, scale: scale, delay: delay))
    }
}
