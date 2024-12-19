import Resolver
import Mixpanel
import RevenueCat
import SwiftUI
import OSLog

fileprivate let logger = Logger(subsystem: "ButterBiscuit.AppScaffold", category: "Main")

public struct AppColorScheme {
    public let accent: Color
    public let accent2: Color
    public let accent3: Color
    
    public let secondaryAccent: Color
    public let secondaryAccent2: Color
    public let secondaryAccent3: Color
    
    public init(
        accent: Color = .blue,
        accent2: Color = .cyan,
        accent3: Color = .blue,
        secondaryAccent: Color = .green,
        secondaryAccent2: Color = .green,
        secondaryAccent3: Color = .green
    ) {
        self.accent = accent
        self.accent2 = accent2
        self.accent3 = accent3
        self.secondaryAccent = secondaryAccent
        self.secondaryAccent2 = secondaryAccent2
        self.secondaryAccent3 = secondaryAccent3
    }
}

@available(iOS 17.0, *)
public enum AppScaffold {
    @MainActor static var initialised: Bool = false
    
    @MainActor private static var _appName: String = ""
    @MainActor public static var appName: String { _appName }
    
    @MainActor private static var _defaultOffering: String = ""
    @MainActor public static var defaultOffering: String { _defaultOffering }
    
    @MainActor private static var _colors: AppColorScheme = AppColorScheme()
    @MainActor public static var colors: AppColorScheme { _colors }
    
    @MainActor public static var accent: Color { colors.accent }
    
    @MainActor
    public static func initialise(
        appName: String,
        defaultOffering: String = "default",
        colors: AppColorScheme? = nil
    ) {
        Self._appName = appName
        Self._defaultOffering = defaultOffering
        
        _colors = colors ?? AppColorScheme()
        
        initialised = true
    }
    
    func useEventTracking(mixPanelKey: String? = nil, thresholds: [Int] = [15, 80]){
        if let mixPanelKey {
            Mixpanel.initialize(token: mixPanelKey, trackAutomaticEvents: true) //TODO: check
        } else if !isPreview {
            logger.error("Mixpanel key is required for event tracking. Please provide a key.")
        }
        
        Resolver.register { EventTrackingService(thresholds: thresholds) }.scope(.shared)
    }
    
    func usePurchases(revenueCatKey: String) {
        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: revenueCatKey)
        Resolver.register { PurchaseViewModel() }.scope(.shared)
    }
    
    func useMockPurchases(isUserSubscribed: Bool) {
        //TODO: implement
    }
    
//    @MainActor
//    public static func assertInitialised() {
//        assert(initialised, "AppScaffold not initialised. Call AppScaffold.initialise() during app init.")
//    }
}

//@available(iOS 16.0, *)
//struct ColorsPreview: View {
//    let colors = AppColorScheme(
//        accent: .cyan
//    )
//    
//    @State var colorScheme: ColorScheme = .light
//    
//    init() {
//        AppScaffold.initialise(appName: "AppScaffold", colors: colors)
//    }
//    
//    var body: some View {
//        ZStack {
//            AppScaffold.colors.accent.ignoresSafeArea()
//        }
//        .preferredColorScheme(colorScheme)
//        .task {
//            try? await Task.sleep(for: .seconds(1.5))
//            colorScheme = .dark
//        }
//    }
//}
//
//@available(iOS 16.0, *)
//#Preview {
//    ColorsPreview()
//}

//public class AppScaffold2 {
//    private init() {}
//    
//    lazy var purchaseVM: PurchaseViewModel = {
//        PurchaseViewModel()
//    }()
//    
//    public static func initialise() {
//        
//    }
//}


//AppScaffold.useName(appName: "")
//AppScaffold.useColors {
//    
//}
//AppScaffold.usePurchases(key: "")
//AppScaffold.useEventTracking(key: "", thresholds: [15, 80])
