import SwiftUI

@available(iOS 16.0, *)
struct OnboardingScreen<Content: View>: View {
    var title: String
    var subTitle: String
    var buttonText: String
    var content: Content
    var onFinish: (() -> Void)? = nil
    
    init(title: String, subTitle: String, buttonText: String = "Continue", @ViewBuilder content: () -> Content, onFinish: (() -> Void)? = nil) {
        self.title = title
        self.subTitle = subTitle
        self.buttonText = buttonText
        self.onFinish = onFinish
        self.content = content()
    }
    
    var body: some View {
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
//                    .font(.title3)
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
            .frame(height: 380)
//            .foregroundStyle(.black)
            .background(OnboardingConfig.overlayColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .ignoresSafeArea(edges: .bottom)
            .offset(CGSize(width: 0.0, height: 50.0))
            .compositingGroup()
            .shadow(color: .black.opacity(0.15), radius: 4)
        }
    }
}
