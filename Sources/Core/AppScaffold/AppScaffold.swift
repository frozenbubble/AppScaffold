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
        
        self.onboardingBackgroundColor = onboardingBackgroundColor ?? Color(.systemBackground)
        self.onboardingOverlayColor = onboardingOverlayColor ?? Color(.systemGray6)
    }
}

public enum AppScaffold {
    @MainActor static var initialised: Bool = false
    
    nonisolated(unsafe) public private(set) static var appName: String = ""
    nonisolated(unsafe) public private(set) static var supportEmail: String = ""
    nonisolated(unsafe) public private(set) static var colors: AppColorScheme = AppColorScheme()
    
    nonisolated(unsafe) public static var accent: Color { colors.accent }
    
    nonisolated(unsafe) public private(set) static var defaultsPrefix: String = ""
    nonisolated(unsafe) public private(set) static var appGroupName: String = ""
    
    @MainActor
    public static func configure(
        appName: String,
        defaultsPrefix: String = "",
        appGroupName: String = "",
        supportEmail: String = "pszappdev@gmail.com",
        colors: AppColorScheme? = nil
    ) {
        Self.appName = appName
        Self.colors = colors ?? AppColorScheme()
        Self.supportEmail = supportEmail
        Self.defaultsPrefix = defaultsPrefix
        Self.appGroupName = appGroupName
        
        // use logger by default for debug builds
//        #if DEBUG
//        useLogger()
//        #endif
        
        
//        Resolver.register { ThemeManager() }.scope(.shared)
    }
}
