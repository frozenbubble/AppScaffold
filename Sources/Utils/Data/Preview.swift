import Foundation
import SwiftData
import SwiftUI

import AppScaffoldCore

@available(iOS 17, macOS 14, *)
@MainActor
func createPreviewContainer(for types: any PersistentModel.Type...) -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)

    do {
        let container = try ModelContainer(for: Schema(types), configurations: config)
        return container
    } catch {
        applog.error("Could not create preview container: \(error)")
        fatalError("Failed to create model container for preview: \(error)")
    }
}

@available(iOS 17, macOS 14, *)
@MainActor
public extension View {
    func withPreviewContainer(for types: any PersistentModel.Type..., autoSave: Bool = true) -> some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        config.allo

        do {
            let container = try ModelContainer(for: Schema(types), configurations: config)
            let context = container.mainContext
            context.autosaveEnabled = autoSave
            return modelContainer(container)
        } catch {
            applog.error("Could not create preview container: \(error)")
            fatalError("Failed to create model container for preview: \(error)")
        }
    }
}
