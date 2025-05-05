@_exported import AppScaffoldPurchases
@_exported import AppScaffoldCore

import SwiftUI

public enum PaywallType {
    case list
    case table
}

@available(iOS 17.0, *)
public extension AppScaffold {
    func configurePaywall(paywallConfiguration: PaywallConfiguration) {
        Resolver.register { }.scope(.application)
    }
}

@available(iOS 17.0, *)
public struct PaywallConfiguration {
    var type: PaywallType
    var features: [FeatureEntry]
    var actions: PaywallActions
    
    // Use AnyView to store the content
    var headerContent: () -> AnyView
    var headlineContent: () -> AnyView
    var otherContent: () -> AnyView
    
    public init(
        type: PaywallType,
        features: [FeatureEntry],
        actions: PaywallActions,
        @ViewBuilder headerContent: @escaping () -> some View,
        @ViewBuilder headlineContent: @escaping () -> some View = { EmptyView() },
        @ViewBuilder otherContent: @escaping () -> some View = { EmptyView() }
    ) {
        self.type = type
        self.features = features
        self.actions = actions
        self.headerContent = { AnyView(headerContent()) }
        self.headlineContent = { AnyView(headlineContent()) }
        self.otherContent = { AnyView(otherContent()) }
    }
}
