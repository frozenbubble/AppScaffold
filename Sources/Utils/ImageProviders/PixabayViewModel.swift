import SwiftUI
import Resolver

import AppScaffoldCore

public struct PixabayResultSet: Sendable, Codable {
    public let total, totalHits: Int
    public let hits: [PixabayImageResult]
}

public struct PixabayImageResult: Sendable, Codable, Identifiable {
    public let id: Int
    public let pageURL: String
    public let type: PixabayTypeEnum
    public let tags: String
    public let previewURL: String
    public let previewWidth, previewHeight: Int
    public let webformatURL: String
    public let webformatWidth, webformatHeight: Int
    public let largeImageURL: String
    public let imageWidth, imageHeight, imageSize, views: Int
    public let downloads, collections, likes, comments: Int
    public let userID: Int
    public let user: String
    public let userImageURL: String

    enum CodingKeys: String, CodingKey {
        case id, pageURL, type, tags, previewURL, previewWidth, previewHeight, webformatURL, webformatWidth, webformatHeight, largeImageURL, imageWidth, imageHeight, imageSize, views, downloads, collections, likes, comments
        case userID = "user_id"
        case user, userImageURL
    }
}

public enum PixabayTypeEnum: String, Sendable, Codable {
    case photo = "photo"
    case illustration = "illustration"
}

@available(iOS 17.0, *)
@MainActor
@Observable
public class PixabayViewModel {
    @Injected @ObservationIgnored var networkImageService: NetworkDownloader
    
    public var inProgress = false
    public var images: [PixabayImageResult] = []
    
    public func search(_ searchTerm: String) async {
        withAnimation { inProgress = true }
        defer { withAnimation { inProgress = false } }
        
        var urlBuilder = URLComponents()
        let key = URLQueryItem(name: "key", value: "43182366-0818ace92dc51858a73b0d6a2")
        let q = URLQueryItem(name: "q", value: searchTerm)
        let type = URLQueryItem(name: "image_type", value: "photo")
        urlBuilder.scheme = "https"
        urlBuilder.host = "pixabay.com"
        urlBuilder.path = "/api/"
        urlBuilder.queryItems = [key, q, type]
        
        guard let url = urlBuilder.url else {
            return
        }
        
        let resultSet: PixabayResultSet? = await networkImageService.fetchData(from: url)
        images = resultSet?.hits ?? []
    }
    
    public func downloadImage(_ image: PixabayImageResult) async -> UIImage? {
        await networkImageService.downloadImage(from: image.largeImageURL)
    }
}

public extension AppScaffold {
    @available(iOS 17.0, *)
    @MainActor
    static func usePixabay() {
        Resolver.register { NetworkDownloader() }.scope(.shared)
        Resolver.register { PixabayViewModel() }.scope(.shared)
    }
}
