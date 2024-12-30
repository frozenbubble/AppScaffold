import Foundation

extension DateComponents {
    func with(year: Int? = nil, month: Int? = nil, day: Int? = nil,
              hour: Int? = nil, minute: Int? = nil, second: Int? = nil, weekday: Int? = nil) -> DateComponents {
        var copy = self
        if let year = year { copy.year = year }
        if let month = month { copy.month = month }
        if let day = day { copy.day = day }
        if let hour = hour { copy.hour = hour }
        if let minute = minute { copy.minute = minute }
        if let second = second { copy.second = second }
        if let weekday = weekday { copy.weekday = weekday }
        return copy
    }
}
