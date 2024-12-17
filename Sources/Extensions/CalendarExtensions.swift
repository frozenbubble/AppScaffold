import Foundation

extension Calendar {
    func generateDates(
        for dateInterval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates = [dateInterval.start]
        
        enumerateDates(
            startingAfter: dateInterval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }
            
            guard date < dateInterval.end else {
                stop = true
                return
            }
            
            dates.append(date)
        }
        
        return dates
    }
    
    func generateDays(for dateInterval: DateInterval) -> [Date] {
        generateDates(
            for: dateInterval,
            matching: dateComponents([.hour, .minute, .second], from: dateInterval.start)
        )
    }
    
    static func weekdayName(from number: Int, style: DateFormatter.Style = .full, locale: Locale = .current) -> String? {
        guard (1...7).contains(number) else { return nil }

        let calendar = Calendar.current
        let symbols: [String]
        
        switch style {
        case .full:
            symbols = calendar.weekdaySymbols
        case .medium:
            symbols = calendar.shortWeekdaySymbols
        case .short:
            symbols = calendar.veryShortWeekdaySymbols
        default:
            return nil // Unsupported style
        }
        
        return symbols[number - 1] // Weekday is 1-based, array is 0-based
    }
}
