import Foundation

extension UserDefaults {
    static func reset(for keys: [String]) {
        let defaults = UserDefaults.standard
        keys.forEach { defaults.removeObject(forKey: $0) }
        defaults.synchronize()
    }
}
