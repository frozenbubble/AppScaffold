import SwiftUI

import AppScaffoldCore
import AppScaffoldPurchases
import AppScaffoldPurchases
import AppScaffoldUI

@available(iOS 17.0, *)
public struct ListPaywall<HeaderContent: View, HeadlineContent: View, OtherContent: View>: View {
    let features: [FeatureEntry]
    let actions: PaywallActions
    let headerContent: HeaderContent
    let headlineContent: HeadlineContent
    let otherContent: OtherContent
    
    @AppService var purchases: PurchaseService
    
    public init(
        features: [FeatureEntry] = [],
        actions: PaywallActions = PaywallActions(),
        @ViewBuilder headerContent: () -> HeaderContent,
        @ViewBuilder headlineContent: () -> HeadlineContent = { EmptyView() },
        @ViewBuilder otherContent: () -> OtherContent = { EmptyView() }
    ) {
        self.features = features
        self.headerContent = headerContent()
        self.headlineContent = headlineContent()
        self.actions = actions
        self.otherContent = otherContent()
    }
    
    public var body: some View {
        if purchases.isUserSubscribedCached {
            content.paidUserFooter()
        } else {
            content.paywallFooter(actions: actions)
        }
    }
    
    var content: some View {
        ListedFeatures(
            primaryBackgroundColor: .secondarySystemGroupedBackground,
            secondaryBackgroundColor: .secondarySystemGroupedBackground,
            features: features,
            headerContent: { headerContent },
            headlineContent: { headlineContent },
            otherContent: { otherContent }
        )
    }
}

@available(iOS 17.0, *)
#Preview {
    _ = AppScaffold.useMockPurchases()
    AppScaffoldUI.configure(colors: .init(
        accent: .yellow
    ), defaultTheme: .light)
    
    return ListPaywall(features: [
        FeatureEntry(icon: "trash", name: "Dummy", description: "Dummy description", basic: .missing, pro: .unlimited),
    ]) {
        Rectangle().fill(.yellow)
    } headlineContent: {
        Text("This is a headline")
    } otherContent: {
        Image(systemName: "carrot")
    }
}
