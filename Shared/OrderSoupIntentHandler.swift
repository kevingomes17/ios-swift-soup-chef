/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Intent handler for `OrderSoupIntent`.
*/

import UIKit

public class OrderSoupIntentHandler: NSObject, OrderSoupIntentHandling {

    /// - Tag: confirm_intent
    public func confirm(intent: OrderSoupIntent, completion: @escaping (OrderSoupIntentResponse) -> Void) {
        
        /*
        The confirm phase provides an opportunity for you to perform any final validation of the intent parameters and to
        verify that any needed services are available. You might confirm that you can communicate with your company’s server
         */
        let soupMenuManager = SoupMenuManager()
        guard let soup = intent.soup,
            let identifier = soup.identifier,
            let menuItem = soupMenuManager.findItem(identifier: identifier) else {
                completion(OrderSoupIntentResponse(code: .failure, userActivity: nil))
                return
        }

        if menuItem.isAvailable == false {
            //  Here's an example of how to use a custom response for a failure case when a particular soup item is unavailable.
            completion(OrderSoupIntentResponse.failureOutOfStock(soup: soup))
            return
        }
        
        // Once the intent is validated, indicate that the intent is ready to handle.
        completion(OrderSoupIntentResponse(code: .ready, userActivity: nil))
    }
    
    public func handle(intent: OrderSoupIntent, completion: @escaping (OrderSoupIntentResponse) -> Void) {

        guard let soup = intent.soup,
            let order = Order(from: intent)
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
        if let formattedWaitTime = formatter.string(from: orderDate, to: readyDate) {
            let response = OrderSoupIntentResponse.success(soup: soup, waitTime: formattedWaitTime)
            response.userActivity = userActivity
            
            completion(response)
        } else {
            // A fallback success code with a less specific message string
            let response = OrderSoupIntentResponse.successReadySoon(soup: soup)
            response.userActivity = userActivity
            
            completion(response)
        }
    }
}
