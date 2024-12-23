import Foundation
import SwiftData
import OSLog

@available(iOS 17, *)
actor ReminderRefresherActor<T: PersistentModel>: ModelActor {
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor
    let processItem: (T) -> ()
    
    init(modelContainer: ModelContainer, processItem: @escaping (T) -> ()) {
        self.modelContainer = modelContainer
        let context = ModelContext(modelContainer)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
        self.processItem = processItem
    }
    
    func refreshReminders() {
        applog.debug("Processing items...")
        let fetchDescriptor: FetchDescriptor<T> = FetchDescriptor<T>() // predicate: #Predicate { $0.isValid }
        let items = try? modelContext.fetch(fetchDescriptor)
        
        guard let items else {
            return
        }
        
        applog.debug("\(items.count) items found.")
        for item in items {
            processItem(item)
        }
    }
}
