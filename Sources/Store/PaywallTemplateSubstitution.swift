import Foundation

import RevenueCat

extension String {
    func resolvePaywallVariables(with product: StoreProduct) -> String  {
        var result = self

        for variable in PaywallVariable.allCases {
            let replacement = substitute(variable: variable, using: product)
            result = result.replacingOccurrences(of: variable.rawValue, with: replacement)
        }

        return result
    }
}

fileprivate func substitute(variable: PaywallVariable, using product: StoreProduct) -> String {
    switch variable {
    case .pricePerPeriod:
        return product.pricePerPeriodString
    case .pricePerMonth:
        return String(format: "%.2f", product.pricePerMonth ?? 0)
    case .offerPeriod:
        if let (period, _, value) = product.offerPeriodDetails {
            return "\(value) \(period)"
        }
        
        return ""
    }
}
