/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This type encapsulates the attributes of a soup order.
*/

import Foundation

public struct Order: Codable {
    
    public enum MenuItemOption: String, Codable, LocalizableShortcutString {
        case cheese = "Cheese"
        case redPepper = "Red Pepper"
        case croutons = "Croutons"

        public static let all: [MenuItemOption] = [.cheese, .redPepper, .croutons]

        var shortcutLocalizationKey: String {
            switch self {
            case .cheese:
                return "CHEESE"
            case .redPepper:
                return "RED_PEPPER"
            case .croutons:
                return "CROUTONS"
            }
        }
    }

    public let date: Date
    public let identifier: UUID
    public let menuItem: MenuItem
    public var quantity: Int
    public var menuItemOptions: Set<MenuItemOption>
    public var total: Decimal {
        return Decimal(quantity) * menuItem.price
    }
    
    public init(date: Date = Date(), identifier: UUID = UUID(), quantity: Int, menuItem: MenuItem, menuItemOptions: Set<MenuItemOption>) {
        self.date = date
        self.identifier = identifier
        self.quantity = quantity
        self.menuItem = menuItem
        self.menuItemOptions = menuItemOptions
    }
}

extension Order: Hashable {
    
    ///  SoupChef considers orders with the same contents (menuItem, quantity, menuItemOptions) to be identical.
    /// The data and idenfier properties are unique to an instance of an order (regardless of contents) and are not
    /// considered when determining equality.
    public static func ==(lhs: Order, rhs: Order) -> Bool {
        return lhs.menuItem == rhs.menuItem &&
            rhs.quantity == lhs.quantity &&
            rhs.menuItemOptions == lhs.menuItemOptions
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(menuItem)
        hasher.combine(quantity)
        hasher.combine(menuItemOptions)
    }
}

extension Order: LocalizableCurrency {

    public var localizedCurrencyValue: String {
        return NumberFormatter.currencyFormatter.string(from: total as NSDecimalNumber) ?? ""
    }
}
