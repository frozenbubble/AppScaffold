import Foundation
import RevenueCat
import OSLog

@available(iOS 17.0, *)
@Observable
public class PurchaseViewModel {
    public var inProgress = false
    public var displayError = false
    public var errorMessage = ""
    public var offerings = [String: Offering]()
    public var isUserSubscribedCached = true
    
    @ObservationIgnored var statusUpdateTime: Date?
    
    private let log: Logger = Logger(subsystem: "ButterBiscuit.MemeCreator", category: "PurchaseViewModel")
    
    @MainActor
    public var subscriptionPlanForToday: String {
        let calendar = Calendar.current
        let today = Date()
        
        let weekOfMonth = calendar.component(.weekOfMonth, from: today)
        
//        if weekOfMonth == 3 {
//            return AppConfig.currentPromotionalOffering ?? AppConfig.currentDefaultOffering
//        } else {
//            return AppConfig.currentDefaultOffering
//        }
        
        //TODO: revise
        return AppScaffold.defaultOffering
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
            //TODO: handle errors
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
            if customerInfo.entitlements["premium"]?.isActive ?? false {
                log.debug("User is on Premiun")
                return true
            } else {
                log.debug("User doesn't have Premium")
                return false
            }
        } catch {
            log.error("Error fetching customer info: \(error.localizedDescription)")
            return false
        }
    }
    
    
//    func getDefaultOffering() async -> Offering? {
//        return await Purchases.shared.offerings().current
//    }
    
    public func isUserEligibleForTrial() async -> Bool {
        do {
            let offerings = try await Purchases.shared.offerings()
            
            // Ensure there's a current offering
            guard let currentOffering = offerings.current else {
                return false
            }
            
            // Iterate through all available packages in the current offering
            for package in currentOffering.availablePackages {
                let product = package.storeProduct
                let eligibility = await Purchases.shared.checkTrialOrIntroDiscountEligibility(product: product)
                
                // If any product is eligible, return true
                if eligibility == .eligible {
                    return true
                }
            }
        } catch {
            // Handle potential errors (e.g., network issues)
            print("Error fetching offerings: \(error)")
        }
        
        // If no products are eligible, return false
        return false
    }
}

