import SwiftUI
import GoogleSignInSwift
import AuthenticationServices
import GoogleSignIn

public enum LoginType {
    case username
    case apple
    case google
}

@available(iOS 16.0, *)
struct LoginView: View {
    var supportedLogins: Set<LoginType> = [.apple, .google]
    
    @AppService private var loginService: LoginService
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            AppIcon()
                .frame(width: 100, height: 100)
            
            if supportedLogins.contains(.username) {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                
                Button("Sign in with Username") {
                    
                }
                .background(AppScaffold.accent)
                .foregroundStyle(.white)
            }
            
            if supportedLogins.contains(.username) && supportedLogins.count > 1 {
                HStack {
                    Rectangle()
                        .fill(.secondary.opacity(0.3))
                        .frame(width: 50, height: 0.5)
                    
                    Text("Or")
                        .foregroundStyle(.secondary)
                        .fontWeight(.light)
                        .opacity(0.5)
                    
                    Rectangle()
                        .fill(.secondary.opacity(0.3))
                        .frame(width: 50, height: 0.5)
                }
            }
            
            if supportedLogins.contains(.apple) {
                SignInWithAppleButton(
                    onRequest: { loginService.setupSigninRequest(request: $0) },
                    onCompletion: {loginService.processSigninResult(result: $0) }
                )
                .frame(width: 300, height: 50)
            }
            
            if supportedLogins.contains(.google) {
                //            GoogleSignInButton {
                //                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                //                      let window = windowScene.windows.first,
                //                      let rootViewController = window.rootViewController else {
                //                    applog.error("Could not obtain root view controller")
                //                    return
                //                }
                //
                //                GIDSignIn.sharedInstance.signIn(
                //                    withPresenting: rootViewController
                //                ) { signInResult, error in
                //
                //                }
                //            }
            }
            
        }
    }
}

@available(iOS 16.0, *)
#Preview {
    AppScaffold.useMockLoginService()
    
    return LoginView()
}
