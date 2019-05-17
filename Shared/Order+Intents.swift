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
        
        orderSoupIntent.soup = menuItem.item
        orderSoupIntent.setImage(INImage(named: menuItem.iconImageName), forParameterNamed: \OrderSoupIntent.soup)
        
        orderSoupIntent.toppings = menuItemToppings.map { (topping) -> INObject in
            let displayString = NSString.deferredLocalizedIntentsString(with: topping.shortcutLocalizationKey) as String
            return INObject(identifier: topping.rawValue, display: displayString)
        }
        
        orderSoupIntent.suggestedInvocationPhrase = NSString.deferredLocalizedIntentsString(with: "ORDER_SOUP_SUGGESTED_PHRASE") as String
        
        return orderSoupIntent
    }
    
    public init?(from intent: OrderSoupIntent) {
        let menuManager = SoupMenuManager()
        guard let menuItem = menuManager.findItem(soup: intent.soup),
            let quantity = intent.quantity
            else { return nil }
        
        let rawToppings = intent.toppings?.compactMap { (toppping) -> MenuItemTopping? in
            guard let toppingID = toppping.identifier else { return nil }
            return MenuItemTopping(rawValue: toppingID)
        } ?? [MenuItemTopping]() // If the result of the map is nil (because `intent.toppings` is nil), provide an empty array.
        
        switch intent.orderType {
        case .unknown:
            self.init(quantity: quantity.intValue, menuItem: menuItem, menuItemToppings: Set(rawToppings))
        case .delivery:
            guard let deliveryLocation = intent.deliveryLocation, let location = deliveryLocation.location else {
                return nil
            }
            self.init(quantity: quantity.intValue,
                      menuItem: menuItem,
                      menuItemToppings: Set(rawToppings),
                      deliveryLocation: Location(name: deliveryLocation.name,
                                                 latitude: location.coordinate.latitude,
                                                 longitude: location.coordinate.longitude))
        case .pickup:
            guard let storeLocation = intent.storeLocation, let location = storeLocation.location else {
                return nil
            }
            self.init(quantity: quantity.intValue,
                      menuItem: menuItem,
                      menuItemToppings: Set(rawToppings),
                      storeLocation: Location(name: storeLocation.name,
                                              latitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude))
        }
    }
}
