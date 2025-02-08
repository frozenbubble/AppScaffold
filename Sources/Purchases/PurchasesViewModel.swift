import Foundation
import RevenueCat
import Resolver

import AppScaffoldCore

@available(iOS 17.0, *)
public protocol PurchaseService {
    var inProgress: Bool { get set }
    var displayError: Bool { get set }
    var errorMessage: String { get set }
    var offerings: [String: Offering] { get set }
    var isUserSubscribedCached: Bool { get set }
    var subscriptionPlanForToday: String { get }
    
    @MainActor func fetchOfferings() async
    @MainActor func updateIsUserSubscribedCached(force: Bool) async
    func isUserSubscribed() async -> Bool
    func isUserEligibleForTrial() async -> Bool
}

@available(iOS 17.0, *)
@Observable
public class PurchaseViewModel: PurchaseService {
    public var inProgress = false
    public var displayError = false
    public var errorMessage = ""
    public var offerings = [String: Offering]()
    public var isUserSubscribedCached = true
    
    @ObservationIgnored var statusUpdateTime: Date?
    @ObservationIgnored private var defaultOfferingName: String?
    @ObservationIgnored private var promoOfferingName: String?
    @ObservationIgnored private var promoPredicate: () -> Bool
    @ObservationIgnored private var entitlementName: String
    
    //TODO revise
    public init(defaultOfferingName: String? = nil, promoOfferingName: String? = nil, entitlement: String = "premium", promoPredicate: @escaping () -> Bool = { false }) {
        self.defaultOfferingName = defaultOfferingName
        self.promoOfferingName = promoOfferingName
        self.promoPredicate = promoPredicate
        self.entitlementName = entitlement
    }
    
//    @MainActor
    public var subscriptionPlanForToday: String {
        return "" //AppScaffold.defaultOffering
    }
    
    @MainActor
    public func fetchOfferings() async {
        defer {
            inProgress = false
        }
        inProgress = true
        do {
            offerings = try await Purchases.shared.offerings().all
        } catch {
            // Handle errors
        }
    }
    
    @MainActor
    public func updateIsUserSubscribedCached(force: Bool = false) async {
        if let statusUpdateTime, statusUpdateTime.timeIntervalSinceNow < 60, !force {
            return
        }
        isUserSubscribedCached = await isUserSubscribed()
        statusUpdateTime = Date()
    }
    
    @MainActor
    public func isUserSubscribed() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            if let premiumEntitlement = customerInfo.entitlements[entitlementName] {
                return premiumEntitlement.isActive
            }
            
            let entitlementNames = customerInfo.entitlements.all.keys
            if !entitlementNames.isEmpty {
                let entitlementNamesStr = entitlementNames.map { "\"\($0)\"" }.joined(separator: ", ")
                applog.warning("Entitlement \"\(entitlementName)\" not found but found \(entitlementNamesStr). Purchases might be misconfigured")
            }
            
            return false
        } catch {
            return false
        }
    }
    
    public func isUserEligibleForTrial() async -> Bool {
        do {
            let offerings = try await Purchases.shared.offerings()
            guard let currentOffering = offerings.current else {
                return false
            }
            for package in currentOffering.availablePackages {
                let product = package.storeProduct
                let eligibility = await Purchases.shared.checkTrialOrIntroDiscountEligibility(product: product)
                if eligibility == .eligible {
                    return true
                }
            }
        } catch {
            return false
        }
        return false
    }
}



public extension AppScaffold {
    @available(iOS 17.0, *)
    @MainActor
    static func usePurchases(revenueCatKey: String, premiumEntitlement: String = "premium") {
        Purchases.logLevel = .info
        let configBuilder = Configuration.Builder(withAPIKey: revenueCatKey)
        
        if !AppScaffold.appGroupName.isEmpty {
            let config = configBuilder
                .with(userDefaults: .init(suiteName: AppScaffold.appGroupName)!)
                .build()
            Purchases.configure(with: config)
        } else {
            Purchases.configure(with: configBuilder.build())
        }
        
//        Purchases.configure(withAPIKey: revenueCatKey)
        Resolver.register { PurchaseViewModel(entitlement: premiumEntitlement) as PurchaseService }.scope(.shared)
    }
}

