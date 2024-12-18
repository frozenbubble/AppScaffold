import Resolver
import OSLog

fileprivate let logger = Logger(subsystem: "ButterBiscuit.AppScaffold", category: "Injection")

@propertyWrapper
public struct SafeInjected<Service> {
    
    private var service: Service?

    public init() {
        if let resolved = Resolver.optional(Service.self) {
            self.service = resolved
        } else {
            let errorMessage = "Resolver Error: \(String(describing: Service.self)) is not registered in the container. You might be missing an AppScaffold initialiser call."
            
            if isPreview {
                print(errorMessage)
            } else {
                logger.warning("\(errorMessage)")
            }
        }
    }

    public var wrappedValue: Service {
        guard let service = service else {
            fatalError("Service \(String(describing: Service.self)) is not available in Resolver.")
        }
        return service
    }
}
