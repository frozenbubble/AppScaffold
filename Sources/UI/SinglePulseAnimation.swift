import SwiftUI
import Foundation

@available(iOS 16.0, macOS 14, *)
public struct SinglePulseEffect: ViewModifier {
    let delay: TimeInterval
    let duration: TimeInterval
    let scaleFactor: CGFloat
    let repeating: Bool
    let gap: TimeInterval
    
    @State private var isPulsing = false
    
    public init(delay: TimeInterval, duration: TimeInterval, scaleFactor: CGFloat, repeating: Bool, gap: TimeInterval) {
        self.delay = delay
        self.duration = duration
        self.scaleFactor = scaleFactor
        self.repeating = repeating
        self.gap = gap
    }
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? scaleFactor : 1.0)
            .animation(.linear(duration: duration), value: isPulsing)
            .task {
                if repeating {
                    await startRepeatingPulse()
                } else {
                    await startSinglePulse()
                }
            }
    }
    
    private func startSinglePulse() async {
        try? await Task.sleep(for: .seconds(delay))
        isPulsing = true
        try? await Task.sleep(for: .seconds(duration))
        isPulsing = false
    }
    
    private func startRepeatingPulse() async {
        try? await Task.sleep(for: .seconds(delay))
        
        while !Task.isCancelled {
            isPulsing = true
            try? await Task.sleep(for: .seconds(duration))
            isPulsing = false
            try? await Task.sleep(for: .seconds(gap))
        }
    }
}

@available(iOS 16.0, macOS 14, *)
public extension View {
    func singlePulseEffect(
        delay: TimeInterval = 0,
        duration: TimeInterval = 0.2,
        scaleFactor: CGFloat = 1.1,
        repeating: Bool = false,
        gap: TimeInterval = 0.5
    ) -> some View {
        modifier(SinglePulseEffect(
            delay: delay,
            duration: duration,
            scaleFactor: scaleFactor,
            repeating: repeating,
            gap: gap
        ))
    }
}

@available(iOS 16.0, macOS 14, *)
#Preview {
    Circle()
        .frame(width: 100, height: 100)
        .singlePulseEffect(delay: 1, duration: 0.2, scaleFactor: 1.1, repeating: true, gap: 2)
}
