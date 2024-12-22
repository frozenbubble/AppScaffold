import SwiftUI
import RevenueCat
import Resolver

@available(iOS 17.0, *)
@Observable
public class MockPurchaseViewModel: PurchaseService {
    public var inProgress: Bool
    public var displayError: Bool
    public var errorMessage: String
    public var offerings: [String: Offering]
    public var isUserSubscribedCached: Bool
    public var subscriptionPlanForToday: String
    
    public init(
        inProgress: Bool = false,
        displayError: Bool = false,
        errorMessage: String = "",
        offerings: [String: Offering] = [:],
        isUserSubscribedCached: Bool = false,
        subscriptionPlanForToday: String = "DefaultPlan"
    ) {
        self.inProgress = inProgress
        self.displayError = displayError
        self.errorMessage = errorMessage
        self.offerings = offerings
        self.isUserSubscribedCached = isUserSubscribedCached
        self.subscriptionPlanForToday = subscriptionPlanForToday
    }
    
    @MainActor public func fetchOfferings() async {
        applog.debug("Fetching offerings")
        inProgress = true
        defer {
            applog.debug("Finished fetching offerings")
            inProgress = false
        }
        
        // Mock behavior
        try? await Task.sleep(for: .seconds(1))
//        offerings = ["mock1": Offering(), "mock2": Offering()]
    }
    
    @MainActor public func updateIsUserSubscribedCached(force: Bool = false) async {
        isUserSubscribedCached = force //TODO: revise
    }
    
    public func isUserSubscribed() async -> Bool {
        return isUserSubscribedCached
    }
    
    public func isUserEligibleForTrial() async -> Bool {
        return true
    }
}

public extension AppScaffold {
    @available(iOS 17.0, *)
    static func useMockPurchases() -> MockPurchaseViewModel {
        let vm = MockPurchaseViewModel()
        Resolver.register { vm as PurchaseService }.scope(.shared)
        
        return vm
    }
}

