@_exported import Resolver
@_exported import SwiftyUserDefaults
import SwiftUI
//import SwiftUIX

public enum AppScaffold {
    @MainActor static var initialised: Bool = false
    
    nonisolated(unsafe) public private(set) static var appName: String = ""
    nonisolated(unsafe) public private(set) static var supportEmail: String = ""
    
    nonisolated(unsafe) public private(set) static var defaultsPrefix: String = ""
    nonisolated(unsafe) public private(set) static var appGroupName: String = ""
    
    @MainActor
    public static func configure(
        appName: String,
        defaultsPrefix: String = "",
        appGroupName: String = "",
        supportEmail: String = "pszappdev@gmail.com"
    ) {
        Self.appName = appName
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
