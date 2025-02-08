import SwiftUI

import AppScaffoldCore

@available(iOS 16.0, *)
public struct OnboardingScreen<Content: View>: View {
    var title: String
    var subTitle: String
    var buttonText: String
    var content: Content
    var onFinish: (() -> Void)? = nil
    
    public init(title: String, subTitle: String, buttonText: String = "Continue", @ViewBuilder content: () -> Content, onFinish: (() -> Void)? = nil) {
        self.title = title
        self.subTitle = subTitle
        self.buttonText = buttonText
        self.onFinish = onFinish
        self.content = content()
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
                Text(subTitle)
                    .multilineTextAlignment(.center)
                    .frame(maxHeight: .infinity, alignment: .top)
                if let onFinish {
                    OnboardingButton(buttonText, action: onFinish)
                        .padding(.bottom, 30)
                        .shadow(color: .black.opacity(0.14), radius: 4)
                }
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
public extension OnboardingScreen where Content == AnyView {
    static var bottomSheetPlaceholder: some View {
        Rectangle()
            .fill(.clear)
            .frame(height: bottomSheetHeight)
    }
}

@available(iOS 16.0, *)
#Preview {
    OnboardingScreen(title: "Title", subTitle: "SubTitle") {
        ScrollView {
            Circle()
            Circle()
            Circle()
            OnboardingScreen.bottomSheetPlaceholder
        }
    } onFinish: {
        
    }
//    .padding(.top)
}
