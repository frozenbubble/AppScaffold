import SwiftUI

import AppScaffoldCore
import SwiftUIX

enum backgroundType {
    case solid
    case blurred
}

@available(iOS 16.0, *)
public struct OnboardingScreen<Content: View>: View {
    var title: String
    var subTitle: String
    var textAlignment: TextAlignment
    var buttonText: String
    var content: Content
    var onFinish: (() -> Void)? = nil
    
    public init(
        title: String,
        subTitle: String,
        textAlignment: TextAlignment = .center,
        buttonText: String = "Continue",
        @ViewBuilder content: () -> Content,
        onFinish: (() -> Void)? = nil
    ) {
        self.title = title
        self.subTitle = subTitle
        self.textAlignment = textAlignment
        self.buttonText = buttonText
        self.onFinish = onFinish
        self.content = content()
    }
    
    public static var bottomSheetHeight: CGFloat { 360 }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Rectangle().fill(.clear)
                content
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.top, 10)
                    .padding(.bottom, 14)
                if textAlignment == .center {
                    Text(subTitle)
                        .multilineTextAlignment(.leading)
                        .frame(maxHeight: .infinity, alignment: .top)
                } else if textAlignment == .leading {
                    Text(subTitle)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else if textAlignment == .trailing {
                    Text(subTitle)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
                
                if let onFinish {
                    OnboardingButton(buttonText, action: onFinish)
                        .padding(.bottom, 30)
                        .shadow(color: .black.opacity(0.14), radius: 4)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: Self.bottomSheetHeight)
            .background {
                AppScaffold.colors.onboardingOverlayColor
//                VisualEffectBlurView(blurStyle: .systemThickMaterial)
            }
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
    OnboardingScreen(title: "Title", subTitle: "SubTitle", textAlignment: .leading) {
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
