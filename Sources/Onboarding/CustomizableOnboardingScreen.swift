import SwiftUI

import AppScaffoldCore

@available(iOS 16.0, *)
public struct CustomizableOnboardingScreen<TopContent: View, BottomContent: View>: View {
    var title: String
    var content: TopContent
    var bottomContent: BottomContent
    var onFinish: (() -> Void)? = nil
    
    public init(title: String, @ViewBuilder topContent: () -> TopContent, @ViewBuilder bottomContent: () -> BottomContent, onFinish: (() -> Void)? = nil) {
        self.title = title
        self.onFinish = onFinish
        self.content = topContent()
        self.bottomContent = bottomContent()
    }
    
    public static var bottomSheetHeight: CGFloat { 330 }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Rectangle().fill(.clear)
                content
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 10)
                    .padding(.bottom, 14)
                bottomContent
                    .frame(maxHeight: .infinity)
//                if let onFinish {
//                    OnboardingButton(buttonText, action: onFinish)
//                        .padding(.bottom, 30)
//                        .shadow(color: .black.opacity(0.14), radius: 4)
//                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: Self.bottomSheetHeight)
            .background(AppScaffold.colors.onboardingOverlayColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .ignoresSafeArea(edges: .bottom)
            .compositingGroup()
            .shadow(color: .black.opacity(0.15), radius: 4)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(AppScaffold.colors.onboardingBackgroundColor)
    }
}

@available(iOS 16.0, *)
public extension CustomizableOnboardingScreen where TopContent == AnyView {
    static var bottomSheetPlaceholder: some View {
        Rectangle()
            .fill(.clear)
            .frame(height: bottomSheetHeight)
    }
}

@available(iOS 16.0, *)
#Preview {
    CustomizableOnboardingScreen(title: "Title") {
        ScrollView {
            Circle()
            Circle()
            Circle()
            OnboardingScreen.bottomSheetPlaceholder
        }
    } bottomContent: {
        Text("asd")
    } onFinish: {
        
    }
//    .padding(.top)
}

