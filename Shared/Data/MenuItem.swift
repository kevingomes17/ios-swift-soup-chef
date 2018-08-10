/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This type encapsulates the attributes of a soup menu item.
*/

import Foundation

public struct MenuItem: Codable, Hashable {
    
    public let itemName: String
    public let shortcutNameKey: String
    public let price: Decimal
    public let iconImageName: String
    public var isAvailable: Bool
    public let isDailySpecial: Bool
    public init(itemName: String, shortcutNameKey: String, price: Decimal, iconImageName: String, isAvailable: Bool, isDailySpecial: Bool) {
        self.itemName = itemName
        self.shortcutNameKey = shortcutNameKey
        self.price = price
        self.iconImageName = iconImageName
        self.isAvailable = isAvailable
        self.isDailySpecial = isDailySpecial
    }
}

extension MenuItem: LocalizableCurrency {
    public var localizedCurrencyValue: String {
        return NumberFormatter.currencyFormatter.string(from: price as NSDecimalNumber) ?? ""
    }
}

extension MenuItem: LocalizableShortcutString {
    
    var shortcutLocalizationKey: String {
        return shortcutNameKey
    }
}
