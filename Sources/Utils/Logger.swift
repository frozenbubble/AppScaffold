import SwiftyBeaver

public let applog = SwiftyBeaver.self

public extension AppScaffold {
    static func useLogger() {
        let console = ConsoleDestination()
        applog.addDestination(console)
    }
}
