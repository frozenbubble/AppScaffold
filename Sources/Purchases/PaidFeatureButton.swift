import SwiftUI

import AppScaffoldCore

@available(iOS 17.0, macOS 14.0, *)
public struct PaidFeatureButton<Label: View>: View {
    @Binding var displayPaywall: Bool
    let action: () -> Void
    let label: Label
    
    @AppService private var purchases: PurchaseService
    
    init(displayPaywall: Binding<Bool>, action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self._displayPaywall = displayPaywall
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button {
            if purchases.isUserSubscribedCached {
                action()
            } else {
                displayPaywall = true
            }
        } label: {
            label
        }
    }
}

