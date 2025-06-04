import Foundation
import Mixpanel
import Resolver

import AppScaffoldCore

public struct EventTrackingService {
    let thresholds: [Int]
    
    var reviewRequests: Int {
        UserDefaults.scaffold.integer(forKey: AppScaffoldStorageKeys.reviewRequests)
    }
    
    public init(thresholds: [Int]) {
        self.thresholds = thresholds
    }
    
    public func trackEvent(_ event: String, _ properties: Properties, isAction: Bool = true) {
        Mixpanel.mainInstance().track(event: event, properties: properties)
        
        if isAction {
            trackAction()
        }
    }

    public func trackAction() {
        let defaults = UserDefaults.scaffold
        let actionsKey = AppScaffoldStorageKeys.actions
        let reviewRequestsKey = AppScaffoldStorageKeys.reviewRequests
        let displayReviewRequestKey = AppScaffoldStorageKeys.displayReviewRequest
        
        let currentReviewRequests = defaults.integer(forKey: reviewRequestsKey)
        let currentActions = defaults.integer(forKey: actionsKey)
        let newActionsCount = currentActions + 1
        
        defaults.set(newActionsCount, forKey: actionsKey)
        
        if currentReviewRequests < thresholds.count && newActionsCount >= thresholds[currentReviewRequests] {
            defaults.set(true, forKey: displayReviewRequestKey)
            defaults.set(currentReviewRequests + 1, forKey: reviewRequestsKey)
        }
    }
    
    public func trackUserProperty(property: String, value: MixpanelType, includeAsAction: Bool = false) {
        Mixpanel.mainInstance().people.set(property: property, to: value)
        
        if includeAsAction {
            trackAction()
        }
    }
    
    public func triggerReviewRequest() {
        let defaults = UserDefaults.scaffold
        let requestCount = defaults.integer(forKey: AppScaffoldStorageKeys.reviewRequests)
        
        defaults.set(requestCount + 1, forKey: AppScaffoldStorageKeys.reviewRequests)
        defaults.set(true, forKey: AppScaffoldStorageKeys.displayReviewRequest)
    }
}

public extension AppScaffold {
    static func useEventTracking(mixPanelKey: String? = nil, thresholds: [Int] = [15, 80]){
        if let mixPanelKey {
#if os(iOS)
            Mixpanel.initialize(token: mixPanelKey, trackAutomaticEvents: true)
#elseif os(macOS)
            Mixpanel.initialize(token: mixPanelKey)
#endif
        } else if !isPreview {
            applog.error("Mixpanel key is required for event tracking. Please provide a key.")
        }
        
        Resolver.register { EventTrackingService(thresholds: thresholds) }.scope(.shared)
    }
}
