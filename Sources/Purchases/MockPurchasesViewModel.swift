import SwiftUI
import RevenueCat
import Resolver

import AppScaffoldCore

@available(iOS 17.0, *)
@Observable
public class MockPurchaseViewModel: PurchaseService {
    public var currentOfferingProducts: [StoreProduct] = []
    public var currentOfferingMetadata: [String : Any] = [:]

    public func purchase(product: RevenueCat.StoreProduct) async throws(PurchaseError) -> CustomerInfo {
        withAnimation { purchaseInProgress = true }
        defer { withAnimation { purchaseInProgress = false } }
        try? await Task.sleep(for: .seconds(1))
        return try! await Purchases.shared.customerInfo()
    }

    public func restorePurchases() async throws(PurchaseError) -> CustomerInfo {
        withAnimation { purchaseInProgress = true }
        defer { withAnimation { purchaseInProgress = false } }
        try? await Task.sleep(for: .seconds(1))
        return try! await Purchases.shared.customerInfo()
    }

    public var currentOffering: RevenueCat.Offering? = nil

    public func fetchCurrentOfferingProducts() async throws {
        withAnimation { fetchingInProgress = true }
        defer { withAnimation { fetchingInProgress = false } }
        try? await Task.sleep(for: .seconds(1.5))

        let weekly = createTestProduct(
            identifier: "mock_product_1_week",
            price: 3.99,
            currencyCode: "USD",
            localizedPrice: "$3.99",
            localizedTitle: "Weekly",
            subscriptionPeriod: SubscriptionPeriod(value: 1, unit: .week)
        )

        let monthly = createTestProduct(
            identifier: "mock_product_1_month",
            price: 4.99,
            currencyCode: "USD",
            localizedPrice: "$4.99",
            localizedTitle: "Monthly",
            subscriptionPeriod: SubscriptionPeriod(value: 1, unit: .month)
        )

        currentOfferingProducts = [weekly, monthly]
//        currentOfferingProducts = []
    }

    public var fetchingInProgress: Bool
    public var purchaseInProgress: Bool
    public var displayError: Bool
    public var errorMessage: String
    public var offerings: [String: Offering]
    public var isUserSubscribedCached: Bool
    public var subscriptionPlanForToday: String
//    public var products: [RevenueCat.StoreProduct] = []

    public init(
        fetchingInProgress: Bool = false,
        purchaseInProgress: Bool = false,
        displayError: Bool = false,
        errorMessage: String = "",
        offerings: [String: Offering] = [:],
        isUserSubscribedCached: Bool = false,
        subscriptionPlanForToday: String = "DefaultPlan"
    ) {
        self.fetchingInProgress = fetchingInProgress
        self.purchaseInProgress = purchaseInProgress
        self.displayError = displayError
        self.errorMessage = errorMessage
        self.offerings = offerings
        self.isUserSubscribedCached = isUserSubscribedCached
        self.subscriptionPlanForToday = subscriptionPlanForToday
    }

    @MainActor public func fetchOfferings() async {
        applog.debug("Fetching offerings")
        fetchingInProgress = true
        defer {
            applog.debug("Finished fetching offerings")
            fetchingInProgress = false
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

fileprivate func createTestProduct(
    identifier: String,
    price: Decimal,
    currencyCode: String,
    localizedPrice: String,
    localizedTitle: String = "Mock Product",
    subscriptionPeriod: SubscriptionPeriod? = nil
) -> StoreProduct {
    let testProduct = TestStoreProduct(
        localizedTitle: localizedTitle,
        price: price,
        localizedPriceString: localizedPrice,
        productIdentifier: identifier,
        productType: subscriptionPeriod != nil ? .autoRenewableSubscription : .consumable, // Adjust as needed
        localizedDescription: "This is a mock product description.",
        subscriptionGroupIdentifier: subscriptionPeriod != nil ? "mock_group" : nil,
        subscriptionPeriod: subscriptionPeriod,
        introductoryDiscount: nil, // Add mock discounts if needed
        discounts: [] // Add mock discounts if needed
    )

    return testProduct.toStoreProduct()
}

