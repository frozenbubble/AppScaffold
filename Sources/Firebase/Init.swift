@_exported import FirebaseCore
@_exported import FirebaseAuth
@_exported import FirebaseFunctions

import AppScaffoldCore

public struct EmulatorConfig {
    let address: String
    let authPort: Int?
    let functionsPort: Int?
    let firestorePort: Int?
    
    public init(address: String, authPort: Int?, functionsPort: Int?, firestorePort: Int?) {
        self.address = address
        self.authPort = authPort
        self.functionsPort = functionsPort
        self.firestorePort = firestorePort
    }
}

public enum AppScaffoldFirebase {
    public static func useFirebase(emulatorConfig: EmulatorConfig? = nil) {
        if FirebaseApp.isDefaultAppConfigured() {
            applog.warning("Firebase app already configured! Skipping...")
            return
        }
        
        applog.info("Configuring Firebase app...")
        FirebaseApp.configure()
        
//        Resolver.register { FirebaseAuthenticator() as LoginService }
        
        #if DEBUG
        if let emulatorConfig {
            applog.warning("Using Firebase emulator")
            
            if let authPort = emulatorConfig.authPort {
                Auth.auth().useEmulator(withHost: emulatorConfig.address, port: authPort)
                applog.warning("Using emulator for Auth at port: \(authPort)")
            }
            
            if let functionsPort = emulatorConfig.functionsPort {
                Functions.functions().useEmulator(withHost: emulatorConfig.address, port: functionsPort)
                applog.warning("Using emulator for Functions at port: \(functionsPort)")
            }
            
//            if let firestorePort = emulatorConfig.firestorePort {
//                applog.warning("Using emulator for Firestore at port: \(firestorePort)")
//            } else {
//                applog.warning("Emulator Firestore not configured")
//            }
        }
        #endif
    }
}
