/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Intent handler for `OrderSoupIntent`.
*/

import UIKit
import CoreLocation
import Intents

public class OrderSoupIntentHandler: NSObject, OrderSoupIntentHandling {
    
    /// - Tag: options
    public func provideToppingsOptions(for intent: OrderSoupIntent, with completion: @escaping ([INObject]?, Error?) -> Void) {
        // Map menu item toppings to custom objects and provide them to the user.
        // The user will be able to choose one or more options.
        print("provideToppingsOptions: ")
        let toppings = Order.MenuItemTopping.all.map { (topping) -> INObject in
            let displayString = NSString.deferredLocalizedIntentsString(with: topping.shortcutLocalizationKey) as String
            return INObject(identifier: topping.rawValue, display: displayString)
        }
        completion(toppings, nil)
    }
    
    public func provideStoreLocationOptions(for intent: OrderSoupIntent, with completion: @escaping ([CLPlacemark]?, Error?) -> Void) {
        print("provideStoreLocationOptions: ")
        completion(Order.storeLocations, nil)
    }
    
    /// - Tag: resolve_intent
    public func resolveToppings(for intent: OrderSoupIntent, with completion: @escaping ([INObjectResolutionResult]) -> Void) {
        print("resolveToppings: ")
        guard let toppings = intent.toppings else {
            completion([INObjectResolutionResult.needsValue()])
            return
        }
        
        if toppings.isEmpty {
            completion([INObjectResolutionResult.notRequired()])
            return
        }
        
        completion(toppings.map { (topping) -> INObjectResolutionResult in
            return INObjectResolutionResult.success(with: topping)
        })
    }
    
    public func resolveSoup(for intent: OrderSoupIntent, with completion: @escaping (SoupResolutionResult) -> Void) {
        print("resolveSoup: ")
        if intent.soup == .unknown {
            completion(SoupResolutionResult.needsValue())
        } else {
            completion(SoupResolutionResult.success(with: intent.soup))
        }
    }
    
    public func resolveQuantity(for intent: OrderSoupIntent, with completion: @escaping (OrderSoupQuantityResolutionResult) -> Void) {
        print("resolveQuantity: ")
        let soupMenuManager = SoupMenuManager()
        guard let menuItem = soupMenuManager.findItem(soup: intent.soup) else {
            completion(OrderSoupQuantityResolutionResult.unsupported())
            return
        }
        
        // A soup order requires a quantity.
        guard let quantity = intent.quantity else {
            completion(OrderSoupQuantityResolutionResult.needsValue())
            return
        }
        
        // If the user asks to order more soups than we have in stock,
        // provide a specific response informing the user why we can't handle the order.
        if quantity.intValue > menuItem.itemsInStock {
            completion(OrderSoupQuantityResolutionResult.unsupported(forReason: .notEnoughInStock))
            return
        }
        
        // Ask the user to confirm that they actually want to order 5 or more soups.
        if quantity.intValue >= 5 {
            completion(OrderSoupQuantityResolutionResult.confirmationRequired(with: quantity.intValue))
            return
        }
        
        completion(OrderSoupQuantityResolutionResult.success(with: quantity.intValue))
    }
    
    public func resolveOrderType(for intent: OrderSoupIntent, with completion: @escaping (OrderTypeResolutionResult) -> Void) {
        print("resolveOrderType: ")
        if intent.orderType == .unknown {
            completion(OrderTypeResolutionResult.needsValue())
        } else {
            completion(OrderTypeResolutionResult.success(with: intent.orderType))
        }
    }
    
    public func resolveDeliveryLocation(for intent: OrderSoupIntent, with completion: @escaping (INPlacemarkResolutionResult) -> Void) {
        print("resolveDeliveryLocation: ")
        guard let deliveryLocation = intent.deliveryLocation else {
            completion(INPlacemarkResolutionResult.needsValue())
            return
        }
        
        completion(INPlacemarkResolutionResult.success(with: deliveryLocation))
    }
    
    public func resolveStoreLocation(for intent: OrderSoupIntent, with completion: @escaping (INPlacemarkResolutionResult) -> Void) {
        print("resolveStoreLocation: ")
        guard let storeLocation = intent.storeLocation else {
            completion(INPlacemarkResolutionResult.needsValue())
            return
        }
        
        completion(INPlacemarkResolutionResult.success(with: storeLocation))
    }
    
    /// - Tag: confirm_intent
    public func confirm(intent: OrderSoupIntent, completion: @escaping (OrderSoupIntentResponse) -> Void) {
        print("confirmIntent: ")
        
        /*
        The confirm phase provides an opportunity for you to perform any final validation of the intent parameters and to
        verify that any needed services are available. You might confirm that you can communicate with your company’s server
         */
        let soupMenuManager = SoupMenuManager()
        guard let menuItem = soupMenuManager.findItem(soup: intent.soup) else {
                completion(OrderSoupIntentResponse(code: .failure, userActivity: nil))
                return
        }

        if menuItem.isAvailable == false {
            //  Here's an example of how to use a custom response for a failure case when a particular soup item is unavailable.
            completion(OrderSoupIntentResponse.failureOutOfStock(soup: intent.soup))
            return
        }
        
        // Once the intent is validated, indicate that the intent is ready to handle.
        completion(OrderSoupIntentResponse(code: .ready, userActivity: nil))
    }
    
    public func handle(intent: OrderSoupIntent, completion: @escaping (OrderSoupIntentResponse) -> Void) {
        print("handleIntent: ")
        guard let order = Order(from: intent)
        else {
            completion(OrderSoupIntentResponse(code: .failure, userActivity: nil))
            return
        }
        
        //  The handle method is also an appropriate place to handle payment via Apple Pay.
        //  A declined payment is another example of a failure case that could take advantage of a custom response.
        
        //  Place the soup order via the order manager.
        let orderManager = SoupOrderDataManager()
        orderManager.placeOrder(order: order)
        
        //  For the success case, we want to indicate a wait time to the user so that they know when their soup order will be ready.
        //  Ths sample uses a hardcoded value, but your implementation could use a time returned by your server.
        let orderDate = Date()
        let readyDate = Date(timeInterval: 10 * 60, since: orderDate) // 10 minutes
        
        let userActivity = NSUserActivity(activityType: NSUserActivity.orderCompleteActivityType)
        userActivity.addUserInfoEntries(from: [NSUserActivity.ActivityKeys.orderID.rawValue: order.identifier])
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        
        let orderDetails = OrderDetails(identifier: nil, display: formatter.string(from: orderDate, to: readyDate) ?? "")
        orderDetails.estimatedTime = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: readyDate)
        orderDetails.total = INCurrencyAmount(amount: NSDecimalNumber(decimal: order.total),
                                              currencyCode: NumberFormatter.currencyFormatter.currencyCode)
        
        let response: OrderSoupIntentResponse
        if let formattedWaitTime = formatter.string(from: orderDate, to: readyDate) {
            response = OrderSoupIntentResponse.success(orderDetails: orderDetails, soup: intent.soup, waitTime: formattedWaitTime)
        } else {
            // A fallback success code with a less specific message string
            response = OrderSoupIntentResponse.successReadySoon(orderDetails: orderDetails, soup: intent.soup)
        }
        
        response.userActivity = userActivity
        completion(response)
    }
}
