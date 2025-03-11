import UIKit

public final class NetworkDownloader: Sendable {
    public func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Failed to load image: HTTP response not OK")
                return nil
            }
            
            guard let image = UIImage(data: data) else {
                print("Failed to create UIImage from data")
                return nil
            }
            
            return image
            
        } catch {
            print("Error downloading image: \(error)")
            return nil
        }
    }
    
    public func fetchData<T: Decodable>(from urlStr: String) async -> T? {
        guard let url = URL(string: urlStr) else {
            print("Invalid URL")
            return nil
        }
        
        return await fetchData(from: url)
    }
    
    public func fetchData<T: Decodable>(from url: URL) async -> T? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Request failed")
                return nil
            }
            
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(T.self, from: data)
            return decodedResponse
            
        } catch {
            print("Failed to fetch or decode data: \(error)")
            return nil
        }
    }
}
