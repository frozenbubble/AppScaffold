import SwiftData

@available(iOS 17, macOS 14, *)
public extension ModelContext {
    func saveIfChanged() throws {
        guard hasChanges else { return }
        try save()
    }
}
