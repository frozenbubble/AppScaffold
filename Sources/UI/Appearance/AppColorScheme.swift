import SwiftUI

public struct AppColorScheme {
    public let accent: Color
    public let accent2: Color
    public let accent3: Color
    
    public let secondaryAccent: Color
    public let secondaryAccent2: Color
    public let secondaryAccent3: Color
    
    public let defaultBackground: Color
    
    public let actionButtonColor1: Color
    public let actionButtonColor2: Color
    public let actionButtonShimmer: Bool
    
    public let actionButtonTextColor: Color
    
    public init(
        accent: Color = .blue,
        accent2: Color = .cyan,
        accent3: Color = .blue,
        secondaryAccent: Color = .green,
        secondaryAccent2: Color = .green,
        secondaryAccent3: Color = .green,
        defaultBackground: Color? = nil,
        actionButtonColor1: Color? = nil,
        actionButtonColor2: Color? = nil,
        actionButtonShimmer: Bool = false,
        actionButtonTextColor: Color? = nil
    ) {
        self.accent = accent
        self.accent2 = accent2
        self.accent3 = accent3
        self.secondaryAccent = secondaryAccent
        self.secondaryAccent2 = secondaryAccent2
        self.secondaryAccent3 = secondaryAccent3
        
        self.defaultBackground = defaultBackground ?? Color(.systemBackground)

        self.actionButtonColor1 = actionButtonColor1 ?? accent.darken(by: 0.05)
        self.actionButtonColor2 = actionButtonColor2 ?? accent.lighten(by: 0.07)
        self.actionButtonShimmer = actionButtonShimmer
        self.actionButtonTextColor = actionButtonTextColor ?? .white
    }
}
