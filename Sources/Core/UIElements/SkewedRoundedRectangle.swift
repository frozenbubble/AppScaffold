import SwiftUI

@available(iOS 15.0, *)
public struct SkewedRoundedRectangle: View {
    var cornerRadius: Double = 8
    var skew: Double = -0.12
    
    public init(cornerRadius: Double = 8, skew: Double = -0.12) {
        self.cornerRadius = cornerRadius
        self.skew = skew
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .transformEffect(CGAffineTransform(a: 1, b: 0, c: skew, d: 1, tx: 0, ty: 0)) // Adjust 'c' for horizontal skew
    }
}

@available(iOS 15.0, *)
#Preview {
    SkewedRoundedRectangle()
        .frame(width: 200, height: 50)
}
