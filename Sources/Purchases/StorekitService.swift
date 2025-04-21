import StoreKit
import SwiftUI

import AppScaffoldCore

@available(iOS 17.0, *)
@Observable
public class StorekitService {
    public private(set) var products: [Product] = []
    
    //TODO: move to purchases configuration / acquire from remote config
    @ObservationIgnored private var productIds: [String]
    
    public init(productIds: [String]) {
        self.productIds = productIds
    }
    
    public func fetchProducts() async {
        do {
            products = try await Product.products(for: productIds)
        } catch {
            applog.error("Failed to fetch products: \(error)")
            products = []
        }
    }
}
