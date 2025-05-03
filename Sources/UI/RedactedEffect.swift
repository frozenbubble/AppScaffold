import SwiftUI

import Shimmer

/**
 Modifier that applies both redaction and shimmer effects to a view.
 The effect is conditionally applied based on the active state.
 */
public struct RedactedEffectModifier: ViewModifier {
    @Binding var active: Bool

    public func body(content: Content) -> some View {
        content
            .redacted(reason: active ? .placeholder : [])
            .shimmering(
                active: active,
                animation: Animation.linear(duration: 1.2).delay(1.8).repeatForever(autoreverses: false),
                bandSize: 0.8
            )
    }
}

public extension View {
    /**
     Applies a redacted placeholder effect with shimmer animation when active

     - Parameter active: Binding to control whether the effect is active
     - Returns: Modified view with redaction and shimmer effects
     */
    func redactedEffect(active: Binding<Bool>) -> some View {
        modifier(RedactedEffectModifier(active: active))
    }
}

#Preview {
    Text("Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nDonec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu.\n\nIn enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a,")
        .redactedEffect(active: .constant(true))
}
