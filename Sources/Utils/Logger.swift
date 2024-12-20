import SwiftyBeaver

public let applog = SwiftyBeaver.self

public extension AppScaffold {
    static func useLogger() {
        let console = ConsoleDestination()
        applog.addDestination(console)
        
//        console.levelString.info = "ℹ️ INFO"
//        console.levelString.debug = "🐞 DEBUG"
//        console.levelString.warning = "⚠️ WARNING"
//        console.levelString.error = "❌ ERROR"
//        console.levelString.verbose = "🔍 VERBOSE"
//        console.levelString.critical = "🚨 CRITICAL"
        
        console.levelString.verbose = "🟣 VERBOSE"
        console.levelString.debug = "🟢 DEBUG"
        console.levelString.info = "🔵 INFO"
        console.levelString.warning = "🟡 WARNING"
        console.levelString.error = "🔴 ERROR"
        console.levelString.critical = "🚨 CRITICAL"
    }
}
