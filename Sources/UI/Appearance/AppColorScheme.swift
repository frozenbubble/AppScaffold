import SwiftUI

public struct AppColorScheme {
    public let accent: Color
    public let accent2: Color
    public let accent3: Color
    
    public let secondaryAccent: Color
    public let secondaryAccent2: Color
    public let secondaryAccent3: Color
    
    public let onboardingBackgroundColor: Color
    public let onboardingOverlayColor: Color
    
    public init(
        accent: Color = .blue,
        accent2: Color = .cyan,
        accent3: Color = .blue,
        secondaryAccent: Color = .green,
        secondaryAccent2: Color = .green,
        secondaryAccent3: Color = .green,
        onboardingBackgroundColor: Color? = nil,
        onboardingOverlayColor: Color? = nil
    ) {
        self.accent = accent
        self.accent2 = accent2
        self.accent3 = accent3
        self.secondaryAccent = secondaryAccent
        self.secondaryAccent2 = secondaryAccent2
        self.secondaryAccent3 = secondaryAccent3
        
        self.onboardingBackgroundColor = onboardingBackgroundColor ?? Color(.systemBackground)
        self.onboardingOverlayColor = onboardingOverlayColor ?? Color(.systemGray6)
    }
}
