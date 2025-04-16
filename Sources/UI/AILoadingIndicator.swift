import SwiftUI

public struct AILoadingView: View {
    var color: Color = .primary
    var size: CGFloat
    
    public init(color: Color = .primary, size: SwiftfulLoadingIndicators.LoadingIndicator.Size? = nil) {
        self.color = color
        self.size = (size ?? .medium).rawValue
    }
    
    public init(color: Color, pxSize: CGFloat) {
        self.color = color
        self.size = pxSize
    }
    
    @State private var pulse = false
    @State private var middlePosition: CGFloat = 0.0
    
    public var body: some View {
        Rectangle()
            .fill(.clear)
            .frame(width: size, height: size)
            .overlay { content }
    }
    
    var content: some View {
        GeometryReader { g in
            let width = g.size.width
            let height = g.size.height
            
            Image(systemName: "sparkle")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.6, height: height * 0.6)
                .pulseAnimation(duration: 1, scale: 1.25, delay: 0.0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 0.1 * width)
                .padding(.bottom, 0.1 * width)
            
            Image(systemName: "sparkle")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.35, height: height * 0.35)
                .pulseAnimation(duration: 1, scale: 1.25, delay: 0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.leading, 0.1 * width)
                .padding(.top, 0.1 * width)
            
            Image(systemName: "sparkle")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.25, height: height * 0.25)
                .pulseAnimation(duration: 1, scale: 1.35, delay: 0.8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(.leading, 0.05 * width)
                .padding(.bottom, 0.05 * width)
        }
    }
}

#Preview {
    AnimatedGradient(color1: .yellow, color2: .mint) {
        AILoadingView(color: .primary, pxSize: 132)
    }
}
