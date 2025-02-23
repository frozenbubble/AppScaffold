import SwiftUI

import AppScaffoldCore

public struct ThemeModifier: ViewModifier {
    @AppStorage(AppScaffoldStorageKeys.appTheme, store: .scaffold)
    var theme = AppScaffoldUI.defaultTheme
    
    public func body(content: Content) -> some View {
        content
            .preferredColorScheme(theme.colorScheme)
    }
}

public extension View {
    func themeAware() -> some View {
        modifier(ThemeModifier())
    }
}
