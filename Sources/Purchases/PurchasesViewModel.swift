import Foundation
import SwiftUI

import RevenueCat
import Resolver

import AppScaffoldCore

public enum PurchaseError: Error {
    case purchaseFailed
    case noEntitlement
    case noPurcaseToRestore
    case restoreFailed
    case noOfferings
    case noCurrentOffering
}

@available(iOS 17.0, *)
public protocol PurchaseService {
    var fetchingInProgress: Bool { get set }
    var purchaseInProgress: Bool { get set }
    var offerings: [String: Offering] { get set }
    var isUserSubscribedCached: Bool { get set }
    var currentOffering: Offering? { get set }
    var currentOfferingProducts: [StoreProduct] { get }

    @MainActor func fetchOfferings() async throws
    @MainActor func updateIsUserSubscribedCached(force: Bool) async
    func isUserSubscribed() async -> Bool
    func isUserEligibleForTrial() async -> Bool
    @MainActor func fetchCurrentOfferingProducts() async throws
    @MainActor func purchase(product: StoreProduct) async throws(PurchaseError) -> CustomerInfo
    @MainActor func restorePurchases() async throws(PurchaseError) -> CustomerInfo
}

@available(iOS 17.0, *)
@Observable
public class PurchaseViewModel: PurchaseService {
    public var fetchingInProgress = false
    public var purchaseInProgress = false

    public var offerings = [String: Offering]()
    public var isUserSubscribedCached = true
    public var currentOffering: Offering?
    public var currentOfferingProducts: [StoreProduct] = []

    @ObservationIgnored
    var statusUpdateTime: Date?
    @ObservationIgnored
    private var entitlementName: String

    @ObservationIgnored
    @OptionalInjected var offeringSelector: OfferingSelector?

    public init(entitlement: String = "premium") {
        self.entitlementName = entitlement
        applog.debug("PurchaseViewModel initialized with entitlement: \(entitlement)")
    }

    @MainActor
    public func fetchOfferings() async throws {
        applog.debug("Fetching RevenueCat offerings")
        withAnimation { fetchingInProgress = true }
        defer { withAnimation { fetchingInProgress = false } }

        var selectedOfferingName: String?
        if let selector = offeringSelector {
            do {
                selectedOfferingName = try await selector.selectOffering()
                if let name = selectedOfferingName {
                    applog.info("Offering selector provided offering name: \(name)")
                } else {
                    applog.info("Offering selector did not provide an offering name")
                }
            } catch {
                applog.error("Offering selector failed: \(error.localizedDescription)")
            }
        } else {
            applog.info("No offering selector available")
        }

        do {
            let offeringsResult = try await Purchases.shared.offerings()
            offerings = offeringsResult.all

            if let name = selectedOfferingName, let selectedOffering = offerings[name] {
                currentOffering = selectedOffering
            } else {
                currentOffering = offeringsResult.current
            }

            applog.info("Fetched \(offerings.count) offerings. Current offering: \(currentOffering?.identifier ?? "none")")
        } catch {
            applog.error("Failed to fetch offerings: \(error.localizedDescription)")
            throw PurchaseError.noOfferings
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
    public func fetchCurrentOfferingProducts() async throws {
        applog.debug("Fetching products for current offering")
        withAnimation { fetchingInProgress = true }
        defer { withAnimation { fetchingInProgress = false } }

        if currentOffering == nil {
            applog.debug("No current offering available, fetching offerings")
            try await fetchOfferings()
        }

        guard let offering = currentOffering else {
            applog.error("No current offering available")
            throw PurchaseError.noCurrentOffering
        }

        let products = offering.availablePackages.map { $0.storeProduct }
        applog.info("Fetched \(products.count) products from offering \(offering.identifier)")
        currentOfferingProducts = products
    }

    @MainActor
    public func purchase(product: StoreProduct) async throws(PurchaseError) -> CustomerInfo {
        applog.info("Attempting to purchase product: \(product.productIdentifier)")
        withAnimation { purchaseInProgress = true }
        defer {
            withAnimation { purchaseInProgress = false }
            Task {
                await updateIsUserSubscribedCached(force: true)
            }
        }

        do {
            let result = try await Purchases.shared.purchase(product: product)
            let customerInfo = result.customerInfo

            if let premiumEntitlement = customerInfo.entitlements[entitlementName], premiumEntitlement.isActive {
                applog.info("Purchase successful for product: \(product.productIdentifier)")
                return customerInfo
            } else {
                applog.error( "Purchase completed but entitlement not found")
                throw PurchaseError.noEntitlement
            }
        } catch {
            applog.error("Purchase failed for product \(product.productIdentifier): \(error.localizedDescription)")
            throw PurchaseError.purchaseFailed
        }
    }

    @MainActor
    public func restorePurchases() async throws(PurchaseError) -> CustomerInfo {
        applog.info("Attempting to restore purchases")
        withAnimation { purchaseInProgress = true }
        defer {
            withAnimation { purchaseInProgress = false }
            Task {
                await updateIsUserSubscribedCached(force: true)
            }
        }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()

            if let premiumEntitlement = customerInfo.entitlements[entitlementName], premiumEntitlement.isActive {
                applog.info("Successfully restored purchase for entitlement: \(entitlementName)")
                return customerInfo
            } else {
                applog.error("No purchases found to restore")
                throw PurchaseError.noPurcaseToRestore
            }
        } catch {
            applog.error("Failed to restore purchases: \(error.localizedDescription)")
            throw PurchaseError.restoreFailed
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

        Resolver.register { PurchaseViewModel(entitlement: premiumEntitlement) as PurchaseService }.scope(.shared)
        applog.info("RevenueCat purchases service configured and registered")
    }
}

