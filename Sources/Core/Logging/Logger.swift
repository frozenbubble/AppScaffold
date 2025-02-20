import SwiftyBeaver

public let applog = SwiftyBeaver.self
nonisolated(unsafe) public fileprivate(set) var loggerInitialized: Bool = false

public extension AppScaffold {
    
    static func useConsoleLogger(
        minLevel: SwiftyBeaver.Level = .verbose,
        logPrintWay: ConsoleDestination.LogPrintWay
    ) {
        if loggerInitialized {
            return
        }
        
        let console = ConsoleDestination()
        console.minLevel = minLevel
        console.logPrintWay = logPrintWay
        
        applog.addDestination(console)
        
        loggerInitialized = true
        
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

//TODO: impelement custom destination
public class CloudDestination: BaseDestination {
    public override func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String,
                       function: String, line: Int, context: Any? = nil) -> String? {
        return nil
    }
}
