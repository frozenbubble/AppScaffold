#if os(iOS)
import UIKit

public extension UIScreen {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
}
#endif
