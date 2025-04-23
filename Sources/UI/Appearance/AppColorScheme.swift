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
    
    public let onboardingButtonColor1: Color
    public let onboardingButtonColor2: Color
    public let onboardingButtonShimmer: Bool
    
    public let paywallButtonTextColor: Color
    
    public init(
        accent: Color = .blue,
        accent2: Color = .cyan,
        accent3: Color = .blue,
        secondaryAccent: Color = .green,
        secondaryAccent2: Color = .green,
        secondaryAccent3: Color = .green,
        onboardingBackgroundColor: Color? = nil,
        onboardingOverlayColor: Color? = nil,
        onboardingButtonColor1: Color? = nil,
        onboardingButtonColor2: Color? = nil,
        onboardingButtonShimmer: Bool = false,
        paywallButtonTextColor: Color? = nil
    ) {
        self.accent = accent
        self.accent2 = accent2
        self.accent3 = accent3
        self.secondaryAccent = secondaryAccent
        self.secondaryAccent2 = secondaryAccent2
        self.secondaryAccent3 = secondaryAccent3
        
        self.onboardingBackgroundColor = onboardingBackgroundColor ?? Color(.systemBackground)
        self.onboardingOverlayColor = onboardingOverlayColor ?? Color(.systemGray6)
        self.onboardingButtonColor1 = onboardingButtonColor1 ?? accent
        self.onboardingButtonColor2 = onboardingButtonColor2 ?? accent
        self.onboardingButtonShimmer = onboardingButtonShimmer
        self.paywallButtonTextColor = paywallButtonTextColor ?? .white
    }
}
