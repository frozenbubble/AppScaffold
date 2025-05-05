import SwiftUI

import AppScaffoldCore
import AppScaffoldPurchases

@available(iOS 17.0, *)
public struct TablePaywall<HeaderContent: View, HeadlineContent: View>: View {
    let features: [FeatureEntry]
    let actions: PaywallActions
    let headerContent: HeaderContent
    let headlineContent: HeadlineContent
    
    @AppService var purchases: PurchaseService
    
    public init(
        features: [FeatureEntry] = [],
        actions: PaywallActions = PaywallActions(),
        @ViewBuilder headerContent: () -> HeaderContent,
        @ViewBuilder headlineContent: () -> HeadlineContent = { EmptyView() }
    ) {
        self.features = features
        self.actions = actions
        self.headerContent = headerContent()
        self.headlineContent = headlineContent()
    }
    
    public var body: some View {
        content.paywallFooter(actions: actions)
    }
    
    public var content: some View {
        TableComparisonFeatures(
            primaryBackgroundColor: .secondarySystemGroupedBackground,
            secondaryBackgroundColor: .secondarySystemGroupedBackground,
            features: features,
            headerContent: { headerContent },
            headlineContent: { headlineContent }
        )
    }
}

@available(iOS 17.0, *)
#Preview {
    _ = AppScaffold.useMockPurchases()
    
    return TablePaywall(features: [
        FeatureEntry(icon: "trash", name: "Dummy", description: "Dummy description", basic: .missing, pro: .unlimited),
    ]) {
        Rectangle().fill(.yellow)
    } headlineContent: {
        Text("This is a headline")
            .font(.title2)
            .fontWeight(.medium)
            .padding()
    }
}
