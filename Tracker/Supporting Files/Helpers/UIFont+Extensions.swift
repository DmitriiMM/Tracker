import UIKit

extension UIFont {
    enum AppFonts: String {
        case regular = "SFProText-Regular"
        case medium = "YSDisplay-Medium"
        case bold = "YSDisplay-Bold"
    }

    static func appFont(_ style: AppFonts, withSize size: CGFloat) -> UIFont {
        guard let font = UIFont(name: style.rawValue, size: size) else {
            return UIFont.systemFont(ofSize: 12)
        }
        return font
    }
}

