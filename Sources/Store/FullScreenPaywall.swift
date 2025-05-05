import SwiftUI

import AppScaffoldCore

@available(iOS 17.0, *)
public struct FullScreenPaywall: View {
    var onPurchase: (() -> Void)? = nil
    
    @Environment(\.dismiss) var dismiss
    @OptionalInjected var config: PaywallConfiguration?
    @AppService var purchases: PurchaseService
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            if let config {
                switch config.type {
                case .list: listPaywall(config)
                case .table: tablePaywall(config)
                }
                
            } else {
                missingConfigView
            }
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 30)
                    .frame(width: 44, height: 44)
                
            }
            .contentShape(.rect)
            .foregroundStyle(.white.opacity(0.65))
            .padding(.top, 44)
            .ignoresSafeArea(.all)
        }
    }
    
    var missingConfigView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundStyle(.yellow)

            Text("Paywall not configured. Call AppScaffold.configurePaywall() during setup")
                .font(.title2)
                .fontWeight(.semibold)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).gradient)
    }
    
    func listPaywall(_ config: PaywallConfiguration) -> some View {
        ListPaywall(
            features: config.features,
            actions: .init(
                purchaseSuccess: { customerInfo in
                    dismiss()
                    config.actions.purchaseSuccess(customerInfo)
                    onPurchase?()
                },
                restoreSuccess: { customerInfo in
                    dismiss()
                    config.actions.purchaseSuccess(customerInfo)
                    onPurchase?()
                }
            ),
            headerContent: { config.headerContent() },
            headlineContent: { config.headlineContent() },
            otherContent: { config.otherContent() }
        )
    }
    
    func tablePaywall(_ config: PaywallConfiguration) -> some View {
        TablePaywall(
            features: config.features,
            actions: config.actions,
            headerContent: { config.headerContent() },
            headlineContent: { config.headlineContent() }//,
//            otherContent: { config.otherContent() }
        )
    }
}

@available(iOS 17.0, *)
public extension View {
    func fullScreenPaywall(isPresented: Binding<Bool>, onPurchase: (() -> Void)? = nil) -> some View {
        self.fullScreenCover(isPresented: isPresented) {
            FullScreenPaywall() {
                onPurchase?()
            }
        }
    }
}
