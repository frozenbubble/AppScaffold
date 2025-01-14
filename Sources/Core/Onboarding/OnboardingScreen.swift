import SwiftUI

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
    
    public var body: some View {
        VStack {
            ZStack {
                Rectangle().fill(.clear)
                content
            }
            
            VStack(spacing: 24) {
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
                        .padding(.bottom, 50)
                        .shadow(color: .black.opacity(0.14), radius: 4)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 410)
//            .foregroundStyle(.black)
            .background(AppScaffold.colors.onboardingOverlayColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .ignoresSafeArea(edges: .bottom)
            .offset(y: 50)
            .compositingGroup()
            .shadow(color: .black.opacity(0.15), radius: 4)
        }
        .background(AppScaffold.colors.onboardingBackgroundColor)
//        .background(.red)
    }
}

@available(iOS 16.0, *)
#Preview {
    OnboardingScreen(title: "Title", subTitle: "SubTitle") {
        Text("Hello World")
    }
}
