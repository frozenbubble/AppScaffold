import Resolver
import OSLog
import SwiftUI

@propertyWrapper
public struct AppService<Service> {
    
    private var service: Service?

    public init() {
        if let resolved = Resolver.optional(Service.self) {
            self.service = resolved
        } else {
            applog.error("Resolver Error: \(String(describing: Service.self)) is not registered in the container. You might be missing an AppScaffold initialiser call.")
        }
    }

    public var wrappedValue: Service {
        guard let service = service else {
            applog.error("Resolver Error: \(String(describing: Service.self)) is not registered in the container. You might be missing an AppScaffold initialiser call.")
            fatalError("Service \(String(describing: Service.self)) is not available in Resolver.")
        }
        
        return service
    }
}

@available(*, deprecated, message: "Use AppService instead.")
public typealias SafeInjected<T> = AppService<T>

//@available(iOS 17.0, *)
//@propertyWrapper
//public struct BindableService<Service: ObservableObject> {
//    private var service: Service?
//    
//    public init() {
//        if let resolved = Resolver.optional(Service.self) {
//            self.service = resolved
//        } else {
//            applog.error("Resolver Error: \(String(describing: Service.self)) is not registered in the container. You might be missing an AppScaffold initialiser call.")
//        }
//    }
//    
//    public var wrappedValue: Bindable<Service> {
//        guard let service = service else {
//            applog.error("Resolver Error: \(String(describing: Service.self)) is not registered in the container. You might be missing an AppScaffold initialiser call.")
//            fatalError("Service \(String(describing: Service.self)) is not available in Resolver.")
//        }
//        return Bindable(service)
//    }
//}

