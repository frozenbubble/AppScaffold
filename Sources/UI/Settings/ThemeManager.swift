import SwiftUI

import AppScaffoldCore

public class ThemeManager: ObservableObject {
    @AppStorage(AppScaffoldStorageKeys.appTheme, store: .scaffold) var themeRawValue = AppScaffoldUI.defaultTheme.rawValue {
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
            .preferredColorScheme(themeManager.theme.colorScheme ?? AppScaffoldUI.defaultTheme.colorScheme)
    }
}

public extension View {
    func themeAware() -> some View {
        modifier(ThemeModifier())
    }
}
