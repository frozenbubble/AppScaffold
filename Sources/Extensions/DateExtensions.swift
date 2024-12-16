import Foundation
import SwiftUI

// MARK: - Date Extension
public extension Date {
    
    // MARK: - Components
    
    /// The year component of the date.
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
    
    /// The month component of the date.
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    /// The day of the month component of the date.
    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }
    
    /// The day of the year component of the date.
    var dayOfYear: Int? {
        Calendar.current.ordinality(of: .day, in: .year, for: self)
    }
    
    /// Checks if the date falls within a leap year.
    var isLeapYear: Bool {
        let year = self.year
        return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0)
    }
    
    // MARK: - Formatting
    
    /// A compact string representation of the date in `dd/MM/yy` format.
    var compactDateStr: String {
        DateFormatter(dateFormat: "dd/MM/yy", calendar: .current).string(from: self)
    }
    
    /// A string representation of the day and month in `dd MMM` format.
    var dayAndMonthStr: String {
        DateFormatter(dateFormat: "dd MMM", calendar: .current).string(from: self)
    }
    
    /// A string representation of the time in `HH:mm` format.
    var timeStr: String {
        DateFormatter(dateFormat: "HH:mm", calendar: .current).string(from: self)
    }
    
    // MARK: - Date Operations
    
    /// Returns a new date by adding a specified number of days.
    /// - Parameter days: The number of days to add.
    func addDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    /// Returns a new date by adding a specified number of hours.
    /// - Parameter hours: The number of hours to add.
    func addHours(_ hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }
    
    /// Returns a new date by adding a specified number of minutes.
    /// - Parameter minutes: The number of minutes to add.
    func addMinutes(_ minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }
    
    /// Returns a new date by adding a specified number of months.
    /// - Parameter months: The number of months to add.
    func addMonths(_ months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    // MARK: - Date Comparisons
    
    /// Checks if the date is in the same day as another date.
    /// - Parameter date: The date to compare.
    func isInSameDayAs(_ date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    /// Checks if the current time is later in the day than another date's time.
    /// - Parameter other: The date to compare.
    func isAfterInDay(of other: Date) -> Bool {
        let calendar = Calendar.current
        let thisTime = calendar.dateComponents([.hour, .minute], from: self)
        let otherTime = calendar.dateComponents([.hour, .minute], from: other)
        return thisTime.hour! > otherTime.hour! || (thisTime.hour! == otherTime.hour! && thisTime.minute! > otherTime.minute!)
    }
    
    // MARK: - Start and End of Periods
    
    /// The start of the day for the date.
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// The start of the week for the date.
    var startOfWeek: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) ?? self
    }
    
    /// The end of the week for the date.
    var endOfWeek: Date {
        Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek) ?? self
    }
    
    /// The start of the month for the date.
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }
    
    /// The end of the month for the date.
    var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? self
    }
    
    // MARK: - Custom Logic
    
    /// Combines the date's date components with another date's time components, with a custom rule rounding minutes to the nearest half hour.
    /// - Parameter timePart: The date from which to extract the time components.
    func overRideTime(with timePart: Date) -> Date? {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        var timeComponents = calendar.dateComponents([.hour, .minute], from: timePart)
        
        // Round minutes to the nearest half hour
        if let minute = timeComponents.minute {
            timeComponents.minute = minute < 30 ? 30 : 0
            if timeComponents.minute == 0, let hour = timeComponents.hour {
                timeComponents.hour = hour + 1
            }
        }
        
        return calendar.date(from: DateComponents(
            year: dateComponents.year,
            month: dateComponents.month,
            day: dateComponents.day,
            hour: timeComponents.hour,
            minute: timeComponents.minute,
            second: 0
        ))
    }
}

// MARK: - Utility Functions

/// Gets all dates between two specified dates.
/// - Parameters:
///   - startDate: The starting date.
///   - endDate: The ending date.
/// - Returns: An array of dates between the two dates.
func getDatesBetween(_ startDate: Date, _ endDate: Date) -> [Date] {
    var dates = [Date]()
    var currentDate = startDate.startOfDay
    
    while currentDate <= endDate.startOfDay {
        dates.append(currentDate)
        currentDate = currentDate.addDays(1)
    }
    return dates
}

/// Gets all days in the month of the specified date.
/// - Parameter date: The date for which to get the days in the month.
/// - Returns: An array of dates representing each day in the month.
func daysInMonth(for date: Date) -> [Date] {
    guard let range = Calendar.current.range(of: .day, in: .month, for: date),
          let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date)) else {
        return []
    }
    
    return range.compactMap { day -> Date? in
        Calendar.current.date(byAdding: .day, value: day - 1, to: startOfMonth)
    }
}

// MARK: - DateFormatter Extension

public extension DateFormatter {
    /// Convenience initializer for creating a `DateFormatter` with a specific date format and calendar.
    /// - Parameters:
    ///   - dateFormat: The date format string.
    ///   - calendar: The calendar to use.
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
}
