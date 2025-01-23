import Foundation

public extension UserDefaults {
    static func unset(_ keys: [String]) {
        let defaults = UserDefaults.standard
        keys.forEach { defaults.removeObject(forKey: $0) }
    }
    
    static func unset(_ key: String) {
        standard.removeObject(forKey: key)
    }
    
    static func reset() {
        if let bundleId = Bundle.main.bundleIdentifier {
            standard.removePersistentDomain(forName: bundleId)
        }
    }
    
    static var scaffold: UserDefaults? {
        UserDefaults(suiteName: "ButterBiscuit.AppScaffold")
    }
}
