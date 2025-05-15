import SwiftUI

public enum AppConfigScaffold: String {
    case dummyValue
}

public extension AppStorage where Value == Bool {
    init(config: AppConfigScaffold, wrappedValue: Value, store: UserDefaults = .scaffold) {
        self.init(wrappedValue: wrappedValue, AppScaffoldStorageKeys.prefixedKey(config.rawValue), store: store)
    }
}

public extension AppStorage where Value == Int {
    init(config: AppConfigScaffold, wrappedValue: Value, store: UserDefaults = .scaffold) {
        self.init(wrappedValue: wrappedValue, AppScaffoldStorageKeys.prefixedKey(config.rawValue), store: store)
    }
}

public extension AppStorage where Value == String {
    init(config: AppConfigScaffold, wrappedValue: Value, store: UserDefaults = .scaffold) {
        self.init(wrappedValue: wrappedValue, AppScaffoldStorageKeys.prefixedKey(config.rawValue), store: store)
    }
}

public extension AppStorage where Value == Double {
    init(config: AppConfigScaffold, wrappedValue: Value, store: UserDefaults = .scaffold) {
        self.init(wrappedValue: wrappedValue, AppScaffoldStorageKeys.prefixedKey(config.rawValue), store: store)
    }
}
