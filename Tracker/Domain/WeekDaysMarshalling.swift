import Foundation

final class WeekDaysMarshalling {
    private let weekdays = Weekday.allCases
    
    func convertWeekDaysToString(_ days: [Weekday]) -> String {
        var result = ""
        for day in weekdays {
            if days.contains(day) {
                result += day.fullName + ","
            }
        }
        return result
    }
    
    func convertStringToWeekDays(_ string: String?) -> [Weekday] {
        guard let string = string else { return [] }
        
        let weekdays = string.components(separatedBy: ",")
        let result = weekdays.compactMap { dayString in
            Weekday.allCases.first { $0.fullName == dayString }
        }
        
        return result
    }
}
