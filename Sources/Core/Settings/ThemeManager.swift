import SwiftUI

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
    @AppStorage(AppScaffoldStorageKeys.appTheme) var themeRawValue = Theme.system.rawValue {
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
    @StateObject var themeManager = ThemeManager()
    
    public func body(content: Content) -> some View {
        content
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.theme.colorScheme)
    }
}

public extension View {
    func themeManager() -> some View {
        modifier(ThemeModifier())
    }
}
