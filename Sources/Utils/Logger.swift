import SwiftyBeaver

public let applog = SwiftyBeaver.self

public extension AppScaffold {
    static func useLogger() {
        let console = ConsoleDestination()
        applog.addDestination(console)
        
        console.levelColor.verbose = "🟣 "
        console.levelColor.debug = "🟢 "
        console.levelColor.info = "🔵 "
        console.levelColor.warning = "🟡 "
        console.levelColor.error = "🔴 "
        console.levelColor.critical = "🚨 "
        console.levelColor.fault = "💥 "
        
//        console.levelColor.verbose = "🔎 "
//        console.levelColor.debug = "🪲 "
//        console.levelColor.info = "ℹ️ "
//        console.levelColor.warning = "🎃 "
//        console.levelColor.error = "🚨 "
//        console.levelColor.critical = "💥 "
//        console.levelColor.fault = "☠️ "
    }
}
