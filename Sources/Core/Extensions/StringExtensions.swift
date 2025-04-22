import Foundation

public extension String {
    func splitCamelCase() -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: "([a-z])([A-Z])", options: [])
            let range = NSRange(location: 0, length: self.utf16.count)
            
            let result = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1 $2")
            
            return result.split(separator: " ").map { String($0) }
        } catch {
            applog.error("Regex error: \(error)")
            return [self]
        }
    }
}
