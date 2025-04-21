import SwiftUI

import AppScaffoldCore
import AppScaffoldPurchases

@available(iOS 17.0, *)
public struct PaywallWithFooter<PaywallContent: View>: View {
    let content: PaywallContent
    
    @AppService var purchases: PurchaseService
    
    public init(@ViewBuilder content: () -> PaywallContent) {
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            
        }
    }
}

@available(iOS 17.0, *)
#Preview {
//    PaywallWithFooter() {
//        
//    }
}
