import UIKit

extension UIFont {
    enum AppFonts: String {
        case regular = "SF-Pro-Text-Regular"
        case medium = "YS-Display-Medium"
        case bold = "YS-Display-Bold"
    }

    static func appFont(_ style: AppFonts, withSize size: CGFloat) -> UIFont {
        guard let font = UIFont(name: style.rawValue, size: size) else {
            return UIFont.systemFont(ofSize: 8)
        }
        return font
    }
}

