@_exported import AppScaffoldPurchases
@_exported import AppScaffoldCore

import SwiftUI

public enum PaywallType {
    case list
    case table
}

@available(iOS 17.0, macOS 14.0, *)
public extension AppScaffold {
    func configurePaywall(paywallConfiguration: PaywallConfiguration) {
        Resolver.register { paywallConfiguration }.scope(.application)
    }
}

@available(iOS 17.0, macOS 14.0, *)
public struct PaywallConfiguration {
    #if os(iOS) || targetEnvironment(macCatalyst)
    var type: PaywallType
    #endif
    var features: [FeatureEntry]
    var actions: PaywallActions
    
    // Use AnyView to store the content
    var headerContent: () -> AnyView
    var headlineContent: () -> AnyView
    var otherContent: () -> AnyView
    
#if os(iOS) || targetEnvironment(macCatalyst)
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
#else
    public init(
        features: [FeatureEntry],
        actions: PaywallActions,
        @ViewBuilder headerContent: @escaping () -> some View,
        @ViewBuilder headlineContent: @escaping () -> some View = { EmptyView() },
        @ViewBuilder otherContent: @escaping () -> some View = { EmptyView() }
    ) {
        self.features = features
        self.actions = actions
        self.headerContent = { AnyView(headerContent()) }
        self.headlineContent = { AnyView(headlineContent()) }
        self.otherContent = { AnyView(otherContent()) }
    }
#endif
}
