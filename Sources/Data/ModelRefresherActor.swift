import Foundation
import SwiftData
import OSLog

@available(iOS 17, *)
public actor ModelRefresherActor <T: PersistentModel>: ModelActor {
    public let modelContainer: ModelContainer
    public let modelExecutor: any ModelExecutor
    let processItem: (T) -> ()
    
    public init(modelContainer: ModelContainer, processItem: @escaping (T) -> ()) {
        self.modelContainer = modelContainer
        let context = ModelContext(modelContainer)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
        self.processItem = processItem
    }
    
    public func processModels() {
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
