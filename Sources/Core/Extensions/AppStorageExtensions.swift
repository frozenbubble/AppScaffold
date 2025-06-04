import SwiftUI

public enum AppConfigScaffold: String {
    case dummyValue
}

public extension DefaultsKey {
    var dummy: DefaultsKey<String?> { .init("dummy", defaultValue: "asd") }
}

//@AppStorage("lofasz") var lofasz

@available(iOS 17, macOS 14.0, *)
public extension AppStorage {
    init<RowValue>(
        wrappedValue: Value = TableColumnCustomization<RowValue>(),
        config: AppConfigScaffold,
        store: UserDefaults? = .scaffold
    ) where Value == TableColumnCustomization<RowValue>, RowValue : Identifiable {
        self.init(wrappedValue: wrappedValue, config.rawValue, store: .scaffold)
    }
}

//public extension AppStorage where Value == Int {
//    init(config: AppConfigScaffold, wrappedValue: Value, store: UserDefaults = .scaffold) {
//        self.init(wrappedValue: wrappedValue, AppScaffoldStorageKeys.prefixedKey(config.rawValue), store: store)
//    }
//}
//
//public extension AppStorage where Value == String {
//    init(config: AppConfigScaffold, wrappedValue: Value, store: UserDefaults = .scaffold) {
//        self.init(wrappedValue: wrappedValue, AppScaffoldStorageKeys.prefixedKey(config.rawValue), store: store)
//    }
//}
//
//public extension AppStorage where Value == Double {
//    init(config: AppConfigScaffold, wrappedValue: Value, store: UserDefaults = .scaffold) {
//        self.init(wrappedValue: wrappedValue, AppScaffoldStorageKeys.prefixedKey(config.rawValue), store: store)
//    }
//}
