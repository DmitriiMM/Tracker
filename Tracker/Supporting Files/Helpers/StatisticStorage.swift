import Foundation

enum Statistic: String, CaseIterable {
    case bestPeriod = "Лучший период"
    case perfectDays = "Идеальные дни"
    case finishedTrackersCount = "Трекеров завершено"
    case averageValue = "Среднее значение"
}

final class StatisticStorage {
    static let shared = StatisticStorage()
    private let userDefaults = UserDefaults.standard
    
    func getStatisticCount(for statistic: Statistic) -> Int {
        return userDefaults.integer(forKey: statistic.rawValue)
    }
    
    func setStatisticCount(for statistic: Statistic, count: Int) {
        userDefaults.set(count, forKey: statistic.rawValue)
    }
}
