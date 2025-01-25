import Foundation
import FirebaseFunctions

public enum FunctionCallError: Error {
    case invalidResponse
    case limitReached
    case unknown
}

public class FirebaseCaller<Parameter: Codable, ResultDTO: Codable> {
    public init() {}
    
    public func callFunction(_ function: String, with parameters: Parameter) async throws -> ResultDTO {
        let functions = Functions.functions()
        
        do {
            let result = try await functions.httpsCallable(function).call(parameters)
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: result.data),
                  let resultDTO = try? JSONDecoder().decode(ResultDTO.self, from: jsonData) else {
                throw FunctionCallError.invalidResponse
            }
            
            return resultDTO
        } catch let error as NSError {
            if let firebaseError = error.userInfo[FunctionsErrorDetailsKey] as? [String: Any],
               let errorCode = firebaseError["code"] as? String,
               errorCode == "resource-exhausted" {
                throw FunctionCallError.limitReached
            } else {
                throw FunctionCallError.unknown
            }
        }
    }
}

@available(iOS 16.0, *)
public class MockFirebaseCaller<Parameter: Codable, ResultDTO: Codable>: FirebaseCaller<Parameter, ResultDTO> {
    private let delaySecondds: Double
    private let result: ResultDTO
    
    public init(delaySecondds: Double, result: ResultDTO) {
        self.delaySecondds = delaySecondds
        self.result = result
    }
    
    override public func callFunction (_ function: String, with parameters: Parameter) async throws -> ResultDTO {
        try? await Task.sleep(for: .seconds(delaySecondds))
        
        return result
    }
}
