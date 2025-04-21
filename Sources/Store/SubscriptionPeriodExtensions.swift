import RevenueCat

extension SubscriptionPeriod.Unit {
    /// Returns an abbreviated code for the subscription period unit.
    var abbreviatedCode: String {
        switch self {
        case .day:   return "day" // Or "dy" if you prefer
        case .week:  return "wk"
        case .month: return "mo"
        case .year:  return "yr"
        @unknown default:
            // Handle any future cases RevenueCat might add
            return "?"
        }
    }
}
