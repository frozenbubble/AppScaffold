import Foundation

public extension UserDefaults {
    func unset(_ keys: [String]) {
        keys.forEach { removeObject(forKey: $0) }
    }
    
    func unset(_ key: String) {
        removeObject(forKey: key)
    }
    
    func reset() {
        if let bundleId = Bundle.main.bundleIdentifier {
            removePersistentDomain(forName: bundleId)
        }
    }
    
    static var scaffold: UserDefaults {
        if !AppScaffold.appGroupName.isEmpty {
            UserDefaults(suiteName: AppScaffold.appGroupName)!
        } else {
            UserDefaults.standard
        }
    }
}
