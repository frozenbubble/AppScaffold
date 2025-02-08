public enum AppScaffoldStorageKeys {
//    public static let reviewRequests = "reviewRequests"
//    public static let actions = "actions"
//    public static let displayReviewRequest = "displayReviewRequest"
//    public static let appTheme = "appTheme"
    
    public static var reviewRequests: String { Self.prefixedKey("reviewRequests") }
    
    public static var actions: String { Self.prefixedKey("actions") }
    
    public static var displayReviewRequest: String { Self.prefixedKey("displayReviewRequest") }
    
    public static var appTheme: String { Self.prefixedKey("appTheme") }
    
    static func prefixedKey(_ key: String) -> String {
        if AppScaffold.defaultsPrefix.isEmpty {
            key
        } else {
            "\(AppScaffold.defaultsPrefix).\(key)"
        }
    }
}
