import Foundation

enum Statistic: String, CaseIterable {
    case bestPeriod
    case perfectDays
    case finishedTrackersCount
    case averageValue
    
    var name: String {
        switch self {
        case .bestPeriod:
            return NSLocalizedString("bestPeriod", comment: "Statistics option")
        case .perfectDays:
            return NSLocalizedString("perfectDays", comment: "Statistics option")
        case .finishedTrackersCount:
            return NSLocalizedString("finishedTrackersCount", comment: "Statistics option")
        case .averageValue:
            return NSLocalizedString("averageValue", comment: "Statistics option")
        }
    }
}

final class StatisticStorage {
    private let userDefaults = UserDefaults.standard
    
    func getStatisticCount(for statistic: Statistic) -> Int {
        return userDefaults.integer(forKey: statistic.name)
    }
    
    func setStatisticCount(for statistic: Statistic, count: Int) {
        userDefaults.set(count, forKey: statistic.name)
    }
}
