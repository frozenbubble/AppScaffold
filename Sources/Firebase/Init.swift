@_exported import FirebaseCore
@_exported import FirebaseAuth
@_exported import FirebaseFunctions
@_exported import FirebaseStorage
@_exported import FirebaseRemoteConfig

import AppScaffoldCore

public struct EmulatorConfig {
    let address: String
    let authPort: Int?
    let functionsPort: Int?
    let firestorePort: Int?
    let remoteConfigPort: Int?

    public init(address: String, authPort: Int? = nil, functionsPort: Int? = nil, firestorePort: Int? = nil, remoteConfigPort: Int? = nil) {
        self.address = address
        self.authPort = authPort
        self.functionsPort = functionsPort
        self.firestorePort = firestorePort
        self.remoteConfigPort = remoteConfigPort
    }
}

public extension AppScaffold {
    static func useFirebase(emulatorConfig: EmulatorConfig? = nil) {
        if FirebaseApp.isDefaultAppConfigured() {
            applog.warning("Firebase app already configured! Skipping...")
            return
        }

        applog.info("Configuring Firebase app...")
        FirebaseApp.configure()

        // Initialize RemoteConfig
        let remoteConfigSettings = RemoteConfigSettings()
        #if DEBUG
        remoteConfigSettings.minimumFetchInterval = 0
        #endif

        RemoteConfig.remoteConfig().configSettings = RemoteConfigSettings()

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

            if let firestorePort = emulatorConfig.firestorePort {
                Storage.storage().useEmulator(withHost: emulatorConfig.address, port: firestorePort)
                applog.warning("Using emulator for Firestore at port: \(firestorePort)")
            } else {
                applog.warning("Emulator Firestore not configured")
            }
        }
        #endif
    }
}
