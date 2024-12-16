import Resolver

public enum AppScaffold {
    @MainActor
    static var initialised: Bool = false
    
    @MainActor
    private static var _appName: String = ""
    
    @MainActor
    public static var appName: String {
        get { _appName }
    }
    
    @MainActor
    private static var _defaultOffering: String = ""
    
    @MainActor
    public static var defaultOffering: String {
        get { _defaultOffering }
    }
    
    @MainActor
    public static func initialise(
        appName: String,
        defaultOffering: String = "default",
        thresholds: [Int] = [15, 80]
    ) {
        Self._appName = appName
        Self._defaultOffering = defaultOffering
        
        Resolver.register {
            EventTrackingService(thresholds: [1, 3, 5, 10])
        }
        
        initialised = true
    }
    
    @MainActor
    public static func assertInitialised() {
        assert(initialised, "AppScaffold not initialised. Call AppScaffold.initialise() during app init.")
    }
}
