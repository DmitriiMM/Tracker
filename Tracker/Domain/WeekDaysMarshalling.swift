import Foundation

final class WeekDaysMarshalling {
    private let weekdays = Weekday.allCases
    
    func convertWeekDaysToString(_ days: [Weekday]) -> String {
        var result = ""
        for day in weekdays {
            if days.contains(day) {
                result += day.rawValue + ","
            }
        }
        return result
    }
    
    func convertStringToWeekDays(_ string: String?) -> [Weekday] {
        var result = [Weekday]()
        if let string = string {
            let weekdays = string.components(separatedBy: ",")
            result = weekdays.compactMap { Weekday(rawValue: $0) }
        }
        return result
    }
}
