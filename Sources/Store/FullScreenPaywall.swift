import SwiftUI
import AppScaffoldUI

import AppScaffoldCore

@available(iOS 17.0, *)
public struct FullScreenPaywall: View {
    var onPurchase: (() -> Void)? = nil
    
    @Environment(\.dismiss) var dismiss
    @OptionalInjected var config: PaywallConfiguration?
    @AppService var purchases: PurchaseService
    
    public init(onPurchase: (() -> Void)? = nil) {
        self.onPurchase = onPurchase
    }
    
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
                    config.actions.purchaseSuccess(customerInfo)
                    dismiss()
                    onPurchase?()
                },
                restoreSuccess: { customerInfo in
                    config.actions.purchaseSuccess(customerInfo)
                    dismiss()
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

@available(iOS 17.0, *)
struct FullScreenPaywallPreview: View {
    @State var displayPaywall = true
    
    var body: some View {
        Button("Present") {
            displayPaywall.toggle()
        }
        .fullScreenPaywall(isPresented: $displayPaywall)
    }
}

@available(iOS 17.0, *)
#Preview {
    _ = AppScaffold.useMockPurchases()
    AppScaffoldUI.configure(colors: .init(
        accent: .yellow
    ), defaultTheme: .light)
    
    Resolver.register {
        PaywallConfiguration(
            type: .list,
            features: [
                FeatureEntry(icon: "trash", name: "Dummy", description: "Dummy description", basic: .missing, pro: .unlimited),
            ],
            actions: .init(),
            headerContent: {Color.yellow}
        )
    }
    
    return FullScreenPaywallPreview()
    
//    return ListPaywall(features: [
//        FeatureEntry(icon: "trash", name: "Dummy", description: "Dummy description", basic: .missing, pro: .unlimited),
//    ]) {
//        Rectangle().fill(.yellow)
//    } headlineContent: {
//        Text("This is a headline")
//    } otherContent: {
//        Image(systemName: "carrot")
//    }
}
