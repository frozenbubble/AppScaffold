import Foundation
import RevenueCat
import Resolver

import AppScaffoldCore

//TODO: make sure purchase and restore implementations are not dependent on single entitlement name

@available(iOS 17.0, *)
public protocol PurchaseService {
    var inProgress: Bool { get set }
    var displayError: Bool { get set }
    var errorMessage: String { get set }
    var offerings: [String: Offering] { get set }
    var isUserSubscribedCached: Bool { get set }
    var currentOffering: Offering? { get set }
    var subscriptionPlanForToday: String { get }

    @MainActor func fetchOfferings() async
    @MainActor func updateIsUserSubscribedCached(force: Bool) async
    func isUserSubscribed() async -> Bool
    func isUserEligibleForTrial() async -> Bool
    @MainActor func fetchCurrentOfferingProducts() async -> [StoreProduct]?
    @MainActor func purchase(product: StoreProduct) async -> Bool
    @MainActor func restorePurchases() async -> Bool
}

@available(iOS 17.0, *)
@Observable
public class PurchaseViewModel: PurchaseService {
    public var inProgress = false
    public var displayError = false
    public var errorMessage = ""
    public var offerings = [String: Offering]()
    public var isUserSubscribedCached = true
    public var currentOffering: Offering?
    public var currentOfferingProducts: [StoreProduct] = []

    @ObservationIgnored
    var statusUpdateTime: Date?
    @ObservationIgnored
    private var defaultOfferingName: String?
    @ObservationIgnored
    private var promoOfferingName: String?
    @ObservationIgnored
    private var promoPredicate: () -> Bool
    @ObservationIgnored
    private var entitlementName: String

    //TODO revise
    public init(defaultOfferingName: String? = nil, promoOfferingName: String? = nil, entitlement: String = "premium", promoPredicate: @escaping () -> Bool = { false }) {
        self.defaultOfferingName = defaultOfferingName
        self.promoOfferingName = promoOfferingName
        self.promoPredicate = promoPredicate
        self.entitlementName = entitlement
        applog.debug("PurchaseViewModel initialized with entitlement: \(entitlement)")
    }

    public var subscriptionPlanForToday: String {
        return "" //AppScaffold.defaultOffering
    }

    @MainActor
    public func fetchOfferings() async {
        applog.debug("Fetching RevenueCat offerings")
        defer { inProgress = false }
        inProgress = true

        do {
            let offeringsResult = try await Purchases.shared.offerings()
            offerings = offeringsResult.all
            currentOffering = offeringsResult.current
            applog.info("Fetched \(offerings.count) offerings. Current offering: \(currentOffering?.identifier ?? "none")")
        } catch {
            displayError = true
            errorMessage = error.localizedDescription
            applog.error("Failed to fetch offerings: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func updateIsUserSubscribedCached(force: Bool = false) async {
        if let statusUpdateTime, statusUpdateTime.timeIntervalSinceNow < 60, !force {
            applog.debug("Skipping subscription status update (last update was \(Int(-statusUpdateTime.timeIntervalSinceNow))s ago)")
            return
        }
        applog.debug("Updating cached subscription status (force: \(force))")
        let wasSubscribed = isUserSubscribedCached
        isUserSubscribedCached = await isUserSubscribed()
        statusUpdateTime = Date()
        if wasSubscribed != isUserSubscribedCached {
            applog.info("Subscription status changed: \(wasSubscribed) -> \(isUserSubscribedCached)")
        }
    }

    @MainActor
    public func isUserSubscribed() async -> Bool {
        applog.debug("Checking if user is subscribed to \(entitlementName)")
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            if let premiumEntitlement = customerInfo.entitlements[entitlementName] {
                let isActive = premiumEntitlement.isActive
                applog.debug("User subscription status for \(entitlementName): \(isActive)")
                return isActive
            }

            let entitlementNames = customerInfo.entitlements.all.keys
            if !entitlementNames.isEmpty {
                let entitlementNamesStr = entitlementNames.map { "\"\($0)\"" }.joined(separator: ", ")
                applog.warning("Entitlement \"\(entitlementName)\" not found but found \(entitlementNamesStr). Purchases might be misconfigured")
            }

            applog.debug("User is not subscribed to \(entitlementName)")
            return false
        } catch {
            applog.error("Failed to check subscription status: \(error.localizedDescription)")
            return false
        }
    }

    public func isUserEligibleForTrial() async -> Bool {
        applog.debug("Checking user eligibility for trial")
        do {
            let offerings = try await Purchases.shared.offerings()
            guard let currentOffering = offerings.current else {
                applog.warning("No current offering available to check trial eligibility")
                return false
            }
            for package in currentOffering.availablePackages {
                let product = package.storeProduct
                let eligibility = await Purchases.shared.checkTrialOrIntroDiscountEligibility(product: product)
                if eligibility == .eligible {
                    applog.info("User is eligible for trial with product \(product.productIdentifier)")
                    return true
                }
            }
            applog.info("User is not eligible for any trials")
        } catch {
            applog.error("Failed to check trial eligibility: \(error.localizedDescription)")
            return false
        }
        return false
    }

    @MainActor
    public func fetchCurrentOfferingProducts() async -> [StoreProduct]? {
        applog.debug("Fetching products for current offering")
        defer { inProgress = false }
        inProgress = true

        if currentOffering == nil {
            applog.debug("No current offering available, fetching offerings")
            await fetchOfferings()
        }
        
        guard let offering = currentOffering else {
            applog.error("No current offering available")
            errorMessage = "Could not fetch products."
            return nil
        }

        let products = offering.availablePackages.map { $0.storeProduct }
        applog.info("Fetched \(products.count) products from offering \(offering.identifier)")
        return products
    }

    @MainActor
    public func purchase(product: StoreProduct) async -> Bool {
        applog.info("Attempting to purchase product: \(product.productIdentifier)")
        defer { inProgress = false }
        inProgress = true

        do {
            let result = try await Purchases.shared.purchase(product: product)
            let customerInfo = result.customerInfo

            if let premiumEntitlement = customerInfo.entitlements[entitlementName], premiumEntitlement.isActive {
                applog.info("Purchase successful for product: \(product.productIdentifier)")
                await updateIsUserSubscribedCached(force: true)
                return true
            } else {
                displayError = true
                errorMessage = "Purchase completed but entitlement not found"
                applog.error(errorMessage)
                return false
            }
        } catch {
            displayError = true
            errorMessage = error.localizedDescription
            applog.error("Purchase failed for product \(product.productIdentifier): \(error.localizedDescription)")
            return false
        }
    }

    @MainActor
    public func restorePurchases() async -> Bool {
        applog.info("Attempting to restore purchases")
        defer { inProgress = false }
        inProgress = true

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()

            if let premiumEntitlement = customerInfo.entitlements[entitlementName], premiumEntitlement.isActive {
                applog.info("Successfully restored purchase for entitlement: \(entitlementName)")
                await updateIsUserSubscribedCached(force: true)
                return true
            } else {
                displayError = true
                errorMessage = "No purchases found to restore"
                applog.error(errorMessage)
                return false
            }
        } catch {
            displayError = true
            errorMessage = error.localizedDescription
            applog.error("Failed to restore purchases: \(error.localizedDescription)")
            return false
        }
    }
}



public extension AppScaffold {
    @available(iOS 17.0, *)
    @MainActor
    static func usePurchases(revenueCatKey: String, premiumEntitlement: String = "premium") {
        applog.info("Configuring RevenueCat with premium entitlement: \(premiumEntitlement)")
        Purchases.logLevel = .info
        let configBuilder = Configuration.Builder(withAPIKey: revenueCatKey)

        if !AppScaffold.appGroupName.isEmpty {
            applog.debug("Using app group \(AppScaffold.appGroupName) for RevenueCat configuration")
            let config = configBuilder
                .with(userDefaults: .init(suiteName: AppScaffold.appGroupName)!)
                .build()
            Purchases.configure(with: config)
        } else {
            applog.debug("Using default RevenueCat configuration (no app group)")
            Purchases.configure(with: configBuilder.build())
        }

//        Purchases.configure(withAPIKey: revenueCatKey)
        Resolver.register { PurchaseViewModel(entitlement: premiumEntitlement) as PurchaseService }.scope(.shared)
        applog.info("RevenueCat purchases service configured and registered")
    }
}

