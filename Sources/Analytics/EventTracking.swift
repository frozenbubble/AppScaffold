import Foundation
import Mixpanel

public struct EventTrackingService {
    let thresholds: [Int]
    
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
        let defaults = UserDefaults.standard
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
}