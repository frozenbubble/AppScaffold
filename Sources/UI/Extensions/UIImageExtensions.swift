#if os(iOS)
import SwiftUI
import AVFoundation
import CryptoKit
import AppScaffoldCore

public extension UIImage {
    func applyFilter(_ filter: CIFilter?, context: CIContext) -> UIImage {
        guard let filter else { return self }
        
        let inputImage = CIImage(image: self)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
        defer {
            // Clear the input image to prevent memory leaks
            filter.setValue(nil, forKey: kCIInputImageKey)
        }
        
        if let outputImage = filter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            
            return UIImage(cgImage: cgImage)
        }
        
        return self
    }
    
    /// Resize image while keeping the aspect ratio. Original image is not modified.
    /// - Parameters:
    ///   - width: A new width in pixels.
    ///   - height: A new height in pixels.
    /// - Returns: Resized image.
    func resize(_ width: Double, _ height: Double) -> UIImage {
        // Keep aspect ratio
        let maxSize = CGSize(width: width, height: height)

        let availableRect = AVFoundation.AVMakeRect(
            aspectRatio: self.size,
            insideRect: .init(origin: .zero, size: maxSize)
        )
        let targetSize = availableRect.size

        // Set scale of renderer so that 1pt == 1px
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        // Resize the image
        let resized = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resized
    }
    
    //TODO: check if we should use height
    func resize(toWidth newWidth: Double) -> UIImage {
        let aspectRatio = self.size.height / self.size.width
        let newHeight = CGFloat(newWidth) * aspectRatio
        
        return resize(newWidth, newWidth)
    }
    
    func temporaryFileURL(filename: String = "SharedImage") -> URL? {
            // Convert the UIImage to JPEG data (you can also use PNG)
            guard let data = self.jpegData(compressionQuality: 1.0) else { return nil }
            
            // Create a temporary file URL with a custom filename
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent(filename).appendingPathExtension("jpg")
            
            // Write data to the temporary file URL
            do {
                try data.write(to: fileURL)
                return fileURL
            } catch {
                applog.error("Error saving image to temporary file: \(error)")
                return nil
            }
        }
}

@available(iOS 15.0, *)
extension UIImage: @retroactive Identifiable {
    public var id: String {
        guard let jpegData = self.jpegData(compressionQuality: 1.0) else {
            return UUID().uuidString
        }
        let hash = SHA256.hash(data: jpegData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
#endif
