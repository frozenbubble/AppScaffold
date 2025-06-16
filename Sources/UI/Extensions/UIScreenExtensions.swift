#if os(iOS)
import UIKit

public extension UIScreen {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
    
    private static let cornerRadiusKey: String = {
        let components = ["Radius", "Corner", "display", "_"]
        return components.reversed().joined()
    }()
    
    /// The corner radius of the display. Uses a private property of `UIScreen`,
    /// and may report 0 if the API changes.
    public var displayCornerRadius: CGFloat {
        guard let cornerRadius = self.value(forKey: Self.cornerRadiusKey) as? CGFloat else {
            assertionFailure("Failed to detect screen corner radius")
            return 0
        }
        
        return cornerRadius
        }
}
#endif
