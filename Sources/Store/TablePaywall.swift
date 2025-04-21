import SwiftUI

import AppScaffoldCore
import AppScaffoldPurchases

@available(iOS 17.0, *)
public struct TablePaywall<HeaderContent: View, HeadlineContent: View>: View {
    let features: [FeatureEntry]
    let headerContent: HeaderContent
    let headlineContent: HeadlineContent
    
    public init(
        features: [FeatureEntry] = [],
        @ViewBuilder headerContent: () -> HeaderContent,
        @ViewBuilder headlineContent: () -> HeadlineContent = { EmptyView() },
    ) {
        self.features = features
        self.headerContent = headerContent()
        self.headlineContent = headlineContent()
    }
    
    public var body: some View {
        TableComparisonFeatures(
            primaryBackgroundColor: .secondarySystemGroupedBackground,
            secondaryBackgroundColor: .secondarySystemGroupedBackground,
            features: features,
            headerContent: { headerContent },
            headlineContent: { headlineContent }
        )
        .paywallFooter()
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
    }
}
