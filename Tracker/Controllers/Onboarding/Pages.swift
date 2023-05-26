import Foundation

enum Pages: CaseIterable {
    case pageZero
    case pageOne
    
    var title: String {
        switch self {
        case .pageZero:
            return "Отслеживайте только то, что хотите"
        case .pageOne:
            return "Даже если это не литры воды и йога"
        }
    }
    
    var index: Int {
        switch self {
        case .pageZero:
            return 0
        case .pageOne:
            return 1
        }
    }
}
