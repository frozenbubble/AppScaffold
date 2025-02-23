import SwiftUI

import AppScaffoldCore

public enum AppScaffoldUI {
    nonisolated(unsafe) public private(set) static var colors: AppColorScheme = AppColorScheme()
    nonisolated(unsafe) public static var accent: Color { colors.accent }
    nonisolated(unsafe) public static var defaultTheme: Theme = .system
    
    public static func configure(colors: AppColorScheme, defaultTheme: Theme) {
        Self.colors = colors
        Self.defaultTheme = defaultTheme
    }
}

public extension AppScaffold {
    static func configureUI(colors: AppColorScheme, defaultTheme: Theme) {
        AppScaffoldUI.configure(colors: colors, defaultTheme: defaultTheme)
    }
}
