import SwiftUI

//TODO: move to AppScaffold
//TODO: try avoiding 2x display
public struct AnimatedGradient<Content: View>: View {
    var color1: Color
    var color2: Color
    var mask: Content
    
    @State private var middlePosition: CGFloat = 0.0
    
    public init (color1: Color, color2: Color, @ViewBuilder mask: () -> Content) {
        self.color1 = color1
        self.color2 = color2
        self.mask = mask()
    }
    
    public var body: some View {
        mask
            .opacity(0)
            .overlay { gradient.mask(mask) }
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                    middlePosition = 1.0
                }
            }
    }
    
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: color1, location: 0.0),
                .init(color: color2, location: middlePosition),
                .init(color: color1, location: 1.0)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
#Preview {
    AnimatedGradient(color1: .red, color2: .blue) {
        Text("Hello, World!")
    }
}