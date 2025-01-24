import Foundation
import FirebaseFunctions
import FirebaseAuth
import AuthenticationServices
//import AppScaffoldCore

//public class FirebaseAuthenticator: LoginService {
//    var currentNonce: String? = nil
//    
//    public func setupSigninRequest(request: ASAuthorizationAppleIDRequest) {
//        let nonce = AppScaffoldCrypto.randomNonceString()
//        currentNonce = nonce
//        
//        request.nonce = AppScaffoldCrypto.sha256(nonce)
//    }
//    
//    public func processSigninResult(result: Result<ASAuthorization, any Error>) {
//        //            isLoading = true
//        
//        if case .failure(let failure) = result {
//            //                isLoading = false
//            //                errorMessage = failure.localizedDescription
//            //                displayError = true
//        } else if case .success(let success) = result, let appleIdCredential = success.credential as? ASAuthorizationAppleIDCredential {
//            guard let currentNonce else {
//                //                    isLoading = false
//                fatalError("Invalid state: a login callback was received but no login request was sent")
//            }
//            
//            guard let appleIdToken = appleIdCredential.identityToken else {
//                //                    isLoading = false
//                applog.error("Unable to fetch id token")
//                return
//            }
//            
//            guard let idTokenString = String(data: appleIdToken, encoding: .utf8) else {
//                //                    isLoading = false
//                applog.error("Unable to serialise token string from data: \(appleIdToken.debugDescription)")
//                return
//            }
//            
//            let credential = OAuthProvider.credential(providerID: .apple, idToken: idTokenString, rawNonce: currentNonce)
//            
//            Task {
//                do {
//                    try await Auth.auth().signIn(with: credential)
//                    DispatchQueue.main.async {
//                        //                        withAnimation {
//                        //                                self.isUserSignedIn = true
//                        //                        }
//                    }
//                } catch {
//                    applog.error("Login failed")
//                }
//                
//                DispatchQueue.main.async {
//                    //                        self.isLoading = false
//                }
//            }
//        } else {
//            //                errorMessage = "Unknown error during login."
//            //                displayError = true
//            //                isLoading = false
//        }
//    }
//    
//    public func isUserSignedIn() -> Bool {
//        Auth.auth().currentUser != nil
//    }
//    
//    public func signOut() throws {
//        try Auth.auth().signOut()
//    }
//    
//    public func deleteAccount() {
//        let user = Auth.auth().currentUser
//        user?.delete()
//    }
//}
