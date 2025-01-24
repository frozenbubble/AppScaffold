import SwiftData

@available(iOS 17, *)
public extension ModelContext {
    func saveIfChanged() throws {
        guard hasChanges else { return }
        try save()
    }
}
