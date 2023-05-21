import Foundation

final class WeekDaysMarshalling {
    private let weekdays = Weekday.allCases
    
    func convertWeekDaysToString(_ days: [Weekday]) -> String {
        var result = ""
        for day in weekdays {
            if days.contains(day) {
                result += "1"
            } else {
                result += "0"
            }
        }
        return result
    }
    
    func convertStringToWeekDays(_ string: String?) -> [Weekday] {
        var result = [Weekday]()
        if let string = string {
            for (index, char) in string.enumerated() {
                if char == "1" {
                    switch index {
                    case 0: result.append(.tuesday)
                    case 1: result.append(.wednesday)
                    case 2: result.append(.thursday)
                    case 3: result.append(.friday)
                    case 4: result.append(.saturday)
                    case 5: result.append(.sunday)
                    case 6: result.append(.monday)
                    default:
                        break
                    }
                }
            }
        }
        return result
    }
}
