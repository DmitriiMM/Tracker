import Foundation

enum Statistic: String, CaseIterable {
    case bestPeriod
    case perfectDays
    case finishedTrackersCount
    case averageValue
    
    var name: String {
        switch self {
        case .bestPeriod:
            return "BEST_PERIOD".localized
        case .perfectDays:
            return "PERFECT_DAYS".localized
        case .finishedTrackersCount:
            return "FINISHED_TRACKERS_COUNT".localized
        case .averageValue:
            return "AVERAGE_VALUE".localized
        }
    }
}

final class StatisticStorage {
    static let shared = StatisticStorage()
    private let userDefaults = UserDefaults.standard
    
    func getStatisticCount(for statistic: Statistic) -> Int {
        return userDefaults.integer(forKey: statistic.name)
    }
    
    func setStatisticCount(for statistic: Statistic, count: Int) {
        userDefaults.set(count, forKey: statistic.name)
    }
}
