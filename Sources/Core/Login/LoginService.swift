import AuthenticationServices

public protocol LoginService {
    func setupSigninRequest(request: ASAuthorizationAppleIDRequest)
    func processSigninResult(result: Result<ASAuthorization, any Error>)
    func isUserSignedIn() -> Bool
    func signOut() throws
    func deleteAccount()
}

public struct MockLoginService: LoginService {
    public func setupSigninRequest(request: ASAuthorizationAppleIDRequest) {
        
    }
    
    public func processSigninResult(result: Result<ASAuthorization, any Error>) {
        
    }
    
    public func isUserSignedIn() -> Bool {
        true
    }
    
    public func signOut() throws {
        
    }
    
    public func deleteAccount() {
        
    }
}

public extension AppScaffold {
    static func useMockLoginService() {
        Resolver.register { MockLoginService() }
    }
}
