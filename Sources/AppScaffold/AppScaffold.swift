import Resolver
import SwiftUI

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
        colors: AppColorScheme? = nil,
        thresholds: [Int] = [15, 80]
    ) {
        Self._appName = appName
        Self._defaultOffering = defaultOffering
        
        Resolver.register {
            EventTrackingService(thresholds: [1, 3, 5, 10])
        }
        
        _colors = colors ?? AppColorScheme()
        
        initialised = true
    }
    
    @MainActor
    public static func assertInitialised() {
        assert(initialised, "AppScaffold not initialised. Call AppScaffold.initialise() during app init.")
    }
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
