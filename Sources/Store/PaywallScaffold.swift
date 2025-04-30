import SwiftUI
import Resolver
import RevenueCatUI
import RevenueCat

import AppScaffoldCore
import AppScaffoldPurchases
import AppScaffoldAnalytics

@available(iOS 17.0, *)
public struct PaywallScaffold<Content: View>: View {
    var offeringName: String?
    var onFinish: (() -> Void)? = nil
    var paywallContent: Content
    
    public init(offering: String? = nil, features: [FeatureEntry] = [], @ViewBuilder paywallContent: () -> Content, onFinish: (() -> Void)? = nil) {
        self.onFinish = onFinish
        self.paywallContent = paywallContent()
        self.offeringName = offering
    }
    
    @Environment(\.dismiss) var dismiss
    @AppService var vm: PurchaseService
    @AppService var eventTracking: EventTrackingService
    @AppStorage(AppScaffoldStorageKeys.actions, store: .scaffold)
    var actions = 0
    
    @State var eligibleForTrial = true
    @State var displayAlert = false
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            if vm.isUserSubscribedCached {
                paywallContent.paidUserFooter()
            } else if let offeringName {
                if let currentOffering = vm.offerings[offeringName] {
                    paywallContent.paywallFooter(
                        offering: currentOffering,
                        condensed: true,
                        purchaseStarted: handlePurchaseStarted,
                        purchaseCompleted: handlePurchaseCompleted,
                        purchaseCancelled: handlePurchaseCancelled,
                        restoreCompleted: handleRestoreCompleted,
                        purchaseFailure: handlePurchaseFailure,
                        restoreFailure: handleRestoreFailure
                    )
                } else if vm.purchaseInProgress || vm.fetchingInProgress {
                    ZStack {
                        paywallContent
                        Rectangle()
                            .fill(Color.secondary)
                            .ignoresSafeArea()
                        ProgressView()
                    }
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color.clear)
                        Text("Could not load subscription plan.")
                    }
                    .onAppear {
                        eventTracking.trackEvent("Error", ["type": "Could not load subscription plan."])
                        applog.error("Could not load subscription plan.")
                    }
                }
            } else {
                paywallContent.paywallFooter(
                    condensed: true,
                    purchaseStarted: handlePurchaseStarted,
                    purchaseCompleted: handlePurchaseCompleted,
                    purchaseCancelled: handlePurchaseCancelled,
                    restoreCompleted: handleRestoreCompleted,
                    purchaseFailure: handlePurchaseFailure,
                    restoreFailure: handleRestoreFailure
                )
            }
        }
        .alert("Something went wrong when processing your purchase", isPresented: $displayAlert) {
            Button("OK", role: .cancel) {
                displayAlert = false
                dismiss()
            }
        }
        .task {
            do {
                try await vm.fetchOfferings()
                await vm.updateIsUserSubscribedCached(force: true)
            } catch {
                applog.error(error)
                //TODO: show alert
            }
        }
    }
    
    func handlePurchaseStarted(product: Package) {
        applog.debug("Purchase started. Product: \(product.identifier) - \(product.storeProduct.productIdentifier)")
    }

    func handlePurchaseCompleted(_ customerInfo: CustomerInfo) {
        updateStatus()
        dismiss()
        onFinish?()

        // TODO: make sure promos work
        // if !(AppConfig.currentPromotionalOffering?.isEmpty ?? true) && offering == AppConfig.currentPromotionalOffering {
        //     actions = AppConfig.minActionsBeforeReviewRequest - 1
        // }
    }

    func handlePurchaseCancelled() {
        updateStatus()
        onFinish?()
        dismiss()
    }

    func handleRestoreCompleted(_ customerInfo: CustomerInfo) {
        updateStatus()
        dismiss()
        onFinish?()
    }

    func handlePurchaseFailure(_ error: Error) {
        updateStatus()
        onFinish?()
        displayAlert = true
    }

    func handleRestoreFailure(_ error: Error) {
        updateStatus()
        onFinish?()
        displayAlert = true
    }
    
    func updateStatus() {
        Task {
            await vm.updateIsUserSubscribedCached(force: true)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    _ = AppScaffold.useMockPurchases()
    AppScaffold.useEventTracking()
    
    return PaywallScaffold() {
        
    }
}

