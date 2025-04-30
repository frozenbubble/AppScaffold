import Foundation

public protocol OfferingSelector {
    @MainActor func selectOffering() async throws -> String?
}
