import SwiftUI
import Resolver
import RevenueCatUI

@available(iOS 17.0, *)
public struct Paywall<Content: View>: View {
    var offering: String?
    var features: [PlanCompareRow]
    var headerContent: Content
    var onFinish: (() -> Void)? = nil
    
    public init(offering: String? = nil, features: [PlanCompareRow] = [], @ViewBuilder headerContent: () -> Content, onFinish: (() -> Void)? = nil) {
        self.onFinish = onFinish
        self.features = features
        self.headerContent = headerContent()
        self.offering = offering
    }
    
    @Environment(\.dismiss) var dismiss
    @Injected var vm: PurchaseViewModel
    
    @AppStorage(AppScaffoldStorageKeys.actions) var actions = 0
    
    @State var eligibleForTrial = true
    @State var displayAlert = false
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            if vm.isUserSubscribedCached {
                PaywallContent(eligibleForTrial: eligibleForTrial, features: features) {
                    headerContent
                }
//                    .paidUserFooter()
            } else if let currentOffering = vm.offerings[offering ?? vm.subscriptionPlanForToday] {
                PaywallContent(eligibleForTrial: eligibleForTrial, features: features) {
                    headerContent
                }
                .paywallFooter(
                    offering: currentOffering,
                    condensed: true,
                    purchaseStarted: { a in
                        print("\(a.identifier)")
                        print(a.storeProduct.productIdentifier)
                    },
                    purchaseCompleted: { customerInro in
                        updateStatus()
                        dismiss()
                        onFinish?()
                        
                    //TODO: make sure promos work
//                        if !(AppConfig.currentPromotionalOffering?.isEmpty ?? true) && offering == AppConfig.currentPromotionalOffering {
//                            actions = AppConfig.minActionsBeforeReviewRequest - 1
//                        }
                    },
                    purchaseCancelled: {
                        updateStatus()
                        onFinish?()
                        dismiss()
                    },
                    restoreCompleted: { _ in
                        updateStatus()
                        dismiss()
                        onFinish?()
                    },
                    purchaseFailure: { _ in
                        updateStatus()
                        onFinish?()
                        displayAlert = true
                    },
                    restoreFailure: { _ in
                        updateStatus()
                        onFinish?()
                        displayAlert = true
                    }
                )
                .alert("Something went wrong when processing your purchase", isPresented: $displayAlert) {
                    Button("OK", role: .cancel) {
                        displayAlert = false
                        dismiss()
                    }
                }
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
        }
        .task {
            await vm.fetchOfferings()
//            await vm.updateIsUserSubscribedCached(force: true)
        }
        .onDisappear {
            print("paywall shown")
        }
    }
    
    func updateStatus() {
        Task {
//            await vm.updateIsUserSubscribedCached(force: true)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    Paywall() {
        
    }
}

