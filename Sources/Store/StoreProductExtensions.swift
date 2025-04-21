import Foundation

import RevenueCat

public extension StoreProduct {
    /// Calculates the monthly price for a product
    /// For non-subscription products, returns the regular price
    var monthlyPrice: Decimal {
        guard let subscriptionPeriod = subscriptionPeriod else {
            return price
        }

        var normalizedPrice = price

        switch subscriptionPeriod.unit {
        case .day:
            normalizedPrice = price * 30 / Decimal(subscriptionPeriod.value)
        case .week:
            normalizedPrice = price * 4 / Decimal(subscriptionPeriod.value)
        case .month:
            normalizedPrice = price / Decimal(subscriptionPeriod.value)
        case .year:
            normalizedPrice = price / Decimal(subscriptionPeriod.value * 12)
        @unknown default:
            return price
        }

        return normalizedPrice
    }

    /// Returns information about the subscription offer period
    /// For non-subscription products, returns nil
    var offerPeriod: (unit: SubscriptionPeriod.Unit, value: Int)? {
        guard let introPrice = introductoryDiscount else {
            return nil
        }

        let subscriptionPeriod = introPrice.subscriptionPeriod
        return (unit: subscriptionPeriod.unit, value: subscriptionPeriod.value)
    }
    
    /**
     Returns the introductory offer period details for a given product.
     - Returns: A tuple containing the period, unit (day, week, month, year), and value,
       or nil if no introductory offer exists
     */
    var offerPeriodDetails: (period: String, unit: String, value: Int)? {
        guard let introInfo = introductoryDiscount else {
            return nil
        }

        let period: String
        let unit: String
        let value: Int

        switch introInfo.subscriptionPeriod.unit {
        case .day:
            unit = "day"
            value = introInfo.subscriptionPeriod.value
            period = value == 1 ? "day" : "days"
        case .week:
            unit = "week"
            value = introInfo.subscriptionPeriod.value
            period = value == 1 ? "week" : "weeks"
        case .month:
            unit = "month"
            value = introInfo.subscriptionPeriod.value
            period = value == 1 ? "month" : "months"
        case .year:
            unit = "year"
            value = introInfo.subscriptionPeriod.value
            period = value == 1 ? "year" : "years"
        @unknown default:
            return nil
        }

        return (period, unit, value)
    }

    func discount(comparedTo other: StoreProduct) -> Decimal {
        guard subscriptionPeriod != nil else {
            return 0
        }

        let normalizedPrice = monthlyPrice
        let normalizedOtherPrice = other.monthlyPrice

        return (normalizedOtherPrice - normalizedPrice) / normalizedOtherPrice
    }
}
