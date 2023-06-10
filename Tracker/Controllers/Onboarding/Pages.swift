import Foundation

enum Pages: CaseIterable {
    case pageZero
    case pageOne
    
    var title: String {
        switch self {
        case .pageZero:
            return "ONBOARDING_FIRST_TITLE".localized
        case .pageOne:
            return "ONBOARDING_SECOND_TITLE".localized
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
