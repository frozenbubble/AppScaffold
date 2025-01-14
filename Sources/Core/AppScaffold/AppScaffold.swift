@_exported import Resolver
import Mixpanel
import RevenueCat
import SwiftUI
import OSLog
//import SwiftUIX

fileprivate let logger = Logger(subsystem: "ButterBiscuit.AppScaffold", category: "Main")

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
        
        self.onboardingBackgroundColor = onboardingBackgroundColor ?? Color.systemBackground
        self.onboardingOverlayColor = onboardingOverlayColor ?? Color.systemGray6
    }
}

public enum AppScaffold {
    @MainActor static var initialised: Bool = false
    
    @MainActor private static var _appName: String = ""
    @MainActor public static var appName: String { _appName }
    
    @MainActor private static var _supportEmail: String = ""
    @MainActor public static var supportEmail: String { _supportEmail }
    
    @MainActor private static var _colors: AppColorScheme = AppColorScheme()
    @MainActor public static var colors: AppColorScheme { _colors }
    
    @MainActor public static var accent: Color { colors.accent }
    
    @MainActor
    public static func configure(
        appName: String,
        supportEmail: String = "pszappdev@gmail.com",
        colors: AppColorScheme? = nil
    ) {
        Self._appName = appName
        _colors = colors ?? AppColorScheme()
        
        // use logger by default for debug builds
        #if DEBUG
        useLogger()
        #endif
        
        
        Resolver.register { ThemeManager() }.scope(.shared)
    }
}
