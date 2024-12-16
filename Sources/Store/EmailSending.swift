import Foundation
import UIKit

public struct EmailService {
    let feedbackEmail: String
    let appName: String
    
    public init(feedbackEmail: String, appName: String) {
        self.feedbackEmail = feedbackEmail
        self.appName = appName
    }
    
    @MainActor
    public func sendEmailViaMailApp() {
        let subject = "User Feedback - \(appName) / \(getAppVersion())"
        let to = feedbackEmail
        let body = "I'm always trying to make \(appName) better. Please tell me how I could improve it."
        
        let urlString = "mailto:\(to)?subject=\(subject)&body=\(body)"
        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
            UIApplication.shared.open(url)
        }
    }
    
    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "Version \(version) (Build \(build))"
        }
        return "Version not available"
    }
}
