import SwiftUI

import AppScaffoldCore

public enum Theme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

public class ThemeManager: ObservableObject {
    @AppStorage(AppScaffoldStorageKeys.appTheme, store: .scaffold) var themeRawValue = Theme.system.rawValue {
        didSet {
            objectWillChange.send()
        }
    }
    
    var theme: Theme {
        get { Theme(rawValue: themeRawValue) ?? .system }
        set { themeRawValue = newValue.rawValue }
    }
}

public struct ThemeModifier: ViewModifier {
    let defaultColorScheme: ColorScheme
    
    @StateObject var themeManager = ThemeManager()
    
    public init(defaultColorScheme: ColorScheme = .light) {
        self.defaultColorScheme = defaultColorScheme
    }
    
    public func body(content: Content) -> some View {
        content
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.theme.colorScheme ?? defaultColorScheme)
    }
}

public extension View {
    func themeManager() -> some View {
        modifier(ThemeModifier())
    }
}

public extension AppScaffold {
    func useThemeManager() {
        Resolver.register { ThemeManager() }.scope(.shared)
    }
}
