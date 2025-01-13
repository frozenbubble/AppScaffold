import CoreImage

public extension CIFilter {
    func clearInput() {
        inputImage = nil
    }
    
    var inputImage: CIImage? {
        get { return value(forKey: kCIInputImageKey) as? CIImage }
        set { setValue(newValue, forKey: kCIInputImageKey) }
    }
}
