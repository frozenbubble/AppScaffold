import SwiftUI

import AppScaffoldCore
import AppScaffoldPurchases
import AppScaffoldUI

@available(iOS 17.0, *)
public struct ListPaywall<HeaderContent: View, HeadlineContent: View, OtherContent: View>: View {
    let features: [FeatureEntry]
    let messages: PaywallMessages
    let actions: PaywallActions
    let headerContent: HeaderContent
    let headlineContent: HeadlineContent
    let otherContent: OtherContent
    
    public init(
        features: [FeatureEntry] = [],
        messages: PaywallMessages = PaywallMessages(),
        actions: PaywallActions = PaywallActions(),
        @ViewBuilder headerContent: () -> HeaderContent,
        @ViewBuilder headlineContent: () -> HeadlineContent = { EmptyView() },
        @ViewBuilder otherContent: () -> OtherContent = { EmptyView() }
    ) {
        self.features = features
        self.headerContent = headerContent()
        self.headlineContent = headlineContent()
        self.actions = actions
        self.messages = messages
        self.otherContent = otherContent()
    }
    
    public var body: some View {
        ListedFeatures(
            primaryBackgroundColor: .secondarySystemGroupedBackground,
            secondaryBackgroundColor: .secondarySystemGroupedBackground,
            features: features,
            headerContent: { headerContent },
            headlineContent: { headlineContent },
            otherContent: { otherContent }
        )
        .paywallFooter()
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
