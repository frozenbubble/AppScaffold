import SwiftUI
import Resolver
import RevenueCatUI
import RevenueCat

@available(iOS 17.0, *)
public struct Paywall<Content: View>: View {
    var offeringName: String?
    var features: [PlanCompareRow]
    var headerContent: Content
    var onFinish: (() -> Void)? = nil
    
    public init(offering: String? = nil, features: [PlanCompareRow] = [], @ViewBuilder headerContent: () -> Content, onFinish: (() -> Void)? = nil) {
        self.onFinish = onFinish
        self.features = features
        self.headerContent = headerContent()
        self.offeringName = offering
    }
    
    @Environment(\.dismiss) var dismiss
    @Injected var vm: PurchaseViewModel
    
    @AppStorage(AppScaffoldStorageKeys.actions) var actions = 0
    
    @State var eligibleForTrial = true
    @State var displayAlert = false
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            if vm.isUserSubscribedCached {
                ListedFeatures(features: features) {
                    headerContent
                }
                .paidUserFooter()
            } else if let offeringName {
                if let currentOffering = vm.offerings[offeringName] {
                    ListedFeatures(features: features) {
                        headerContent
                    }
                    .paywallFooter(
                        offering: currentOffering,
                        condensed: true,
                        purchaseStarted: handlePurchaseStarted,
                        purchaseCompleted: handlePurchaseCompleted,
                        purchaseCancelled: handlePurchaseCancelled,
                        restoreCompleted: handleRestoreCompleted,
                        purchaseFailure: handlePurchaseFailure,
                        restoreFailure: handleRestoreFailure
                    )
                } else if vm.inProgress {
                    ZStack {
                        Rectangle()
                            .fill(Color.clear)
                        ProgressView()
                    }
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color.clear)
                        Text("Could not load subscription plan.")
                    }
                }
            } else {
                ListedFeatures(features: features) {
                    headerContent
                }
                .paywallFooter(
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
            await vm.fetchOfferings()
            await vm.updateIsUserSubscribedCached(force: true)
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
    Resolver.register { PurchaseViewModel() }
    
    return Paywall() {
        
    }
}

