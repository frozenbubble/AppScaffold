import SwiftUI

import Resolver

import AppScaffoldCore

/// Represents a single feature or change in a version
public struct WhatsNewItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let icon: String

    public init(title: String, description: String, icon: String) {
        self.title = title
        self.description = description
        self.icon = icon
    }
}

/// Manages the state and configuration of the What's New feature
@available(iOS 17.0, *)
@Observable
public final class WhatsNewManager {
    var isPresented = false
    private let currentVersion: String
    private let userDefaults = UserDefaults.standard

    let items: [WhatsNewItem]

    private var lastShownVersionKey: String { "lastShownWhatsNewVersion" }

    public init(currentVersion: String, items: [WhatsNewItem]) {
        self.currentVersion = currentVersion
        self.items = items
    }

    public func shouldShow() -> Bool {
        let lastShown = userDefaults.string(forKey: lastShownVersionKey)
        return lastShown != currentVersion
    }

    public func show() {
        isPresented = true
    }

    public func dismiss() {
        isPresented = false
        userDefaults.set(currentVersion, forKey: lastShownVersionKey)
    }
}

@available(iOS 17.0, *)
public extension AppScaffold {
    static func configureWhatsNew(version: String, items: [WhatsNewItem]) {
        let manager = WhatsNewManager(currentVersion: version, items: items)
        Resolver.register { manager as WhatsNewManager }
    }
}
