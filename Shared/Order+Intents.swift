/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Conversion utilities for converting between `Order` and `OrderSoupIntent`.
*/

import Foundation
import Intents

extension Order {
    public var intent: OrderSoupIntent {
        let orderSoupIntent = OrderSoupIntent()
        orderSoupIntent.quantity = quantity as NSNumber
        
        let displayString = NSString.deferredLocalizedIntentsString(with: menuItem.shortcutLocalizationKey) as String
        orderSoupIntent.soup = INObject(identifier: menuItem.itemName, display: displayString)
        orderSoupIntent.setImage(INImage(named: menuItem.iconImageName), forParameterNamed: \OrderSoupIntent.soup)
        
        orderSoupIntent.options = menuItemOptions.map { (option) -> INObject in
            let displayString = NSString.deferredLocalizedIntentsString(with: option.shortcutLocalizationKey) as String
            return INObject(identifier: option.rawValue, display: displayString)
        }
        
        orderSoupIntent.suggestedInvocationPhrase = NSString.deferredLocalizedIntentsString(with: "ORDER_SOUP_SUGGESTED_PHRASE") as String
        
        return orderSoupIntent
    }
    
    public init?(from intent: OrderSoupIntent) {
        let menuManager = SoupMenuManager()
        guard let soupID = intent.soup?.identifier,
            let menuItem = menuManager.findItem(identifier: soupID),
            let quantity = intent.quantity
            else { return nil }
        
        let rawOptions = intent.options?.compactMap { (option) -> MenuItemOption? in
            guard let optionID = option.identifier else { return nil }
            return MenuItemOption(rawValue: optionID)
        } ?? [MenuItemOption]() // If the result of the map is nil (because `intent.options` is nil), provide an empty array.
        
        self.init(quantity: quantity.intValue, menuItem: menuItem, menuItemOptions: Set(rawOptions))
    }
}
