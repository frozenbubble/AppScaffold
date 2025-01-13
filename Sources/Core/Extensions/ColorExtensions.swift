import SwiftUI

@available(iOS 15.0, *)
public extension Color {
    
    // MARK: - Initializers
    
    /// Initializes a `Color` from a hexadecimal string.
    /// - Parameter hex: The hexadecimal string representing the color (e.g., `"#FF0000"` or `"FF0000"`).
    init(hex: String) {
        var sanitizedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        sanitizedHex = sanitizedHex.replacingOccurrences(of: "#", with: "")
        
        let scanner = Scanner(string: sanitizedHex)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let r = (hexNumber & 0xff0000) >> 16
            let g = (hexNumber & 0x00ff00) >> 8
            let b = hexNumber & 0x0000ff
            
            self.init(
                .sRGB,
                red: Double(r) / 255,
                green: Double(g) / 255,
                blue: Double(b) / 255,
                opacity: 1
            )
            return
        }
        
        // Default to black if the hex string is invalid
        self.init(.sRGB, red: 0, green: 0, blue: 0, opacity: 1)
    }
    
    // MARK: - Hex Representation
    
    /// Converts the `Color` to a hexadecimal string representation.
    /// - Returns: A `String` containing the hexadecimal color code (e.g., `"FF0000"`).
    var hex: String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let r = Int(red * 255)
            let g = Int(green * 255)
            let b = Int(blue * 255)
            
            return String(format: "%02X%02X%02X", r, g, b)
        }
        
        return "000000" // Default to black if unable to extract components
    }
    
    // MARK: - Brightness Adjustment
    
    /// Adjusts the brightness of the `Color`.
    /// - Parameter amount: The amount to adjust the brightness, where `-1.0` darkens fully and `1.0` brightens fully.
    /// - Returns: A new `Color` with the adjusted brightness.
    func adjustBrightness(by amount: Double) -> Color {
        let clampedAmount = min(max(amount, -1.0), 1.0) // Clamp amount to [-1, 1]
        
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return self // Return the original color if HSB conversion fails
        }
        
        // Adjust brightness and clamp to [0, 1]
        let adjustedBrightness = min(max(brightness + CGFloat(clampedAmount), 0), 1)
        
        let adjustedUIColor = UIColor(hue: hue, saturation: saturation, brightness: adjustedBrightness, alpha: alpha)
        return Color(adjustedUIColor)
    }
    
    /// Darkens the `Color` by a specified amount.
    /// - Parameter amount: The amount to darken the color (0.0 to 1.0).
    /// - Returns: A new `Color` that is darker.
    func darken(by amount: Double) -> Color {
        adjustBrightness(by: -amount)
    }
    
    /// Lightens the `Color` by a specified amount.
    /// - Parameter amount: The amount to lighten the color (0.0 to 1.0).
    /// - Returns: A new `Color` that is lighter.
    func lighten(by amount: Double) -> Color {
        adjustBrightness(by: amount)
    }
    
    // MARK: - Alpha Component
    
    /// Retrieves the alpha (opacity) component of the `Color`.
    /// - Returns: A `CGFloat` representing the alpha value (0.0 to 1.0), or `nil` if extraction fails.
    var alpha: CGFloat? {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Extract RGBA components
        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return alpha
        }
        return nil // Return nil if RGBA extraction fails
    }
}
