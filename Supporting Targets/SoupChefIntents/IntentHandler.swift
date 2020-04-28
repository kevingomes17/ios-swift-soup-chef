/*
See LICENSE folder for this sample’s licensing information.

Abstract:
IntentHandler that vends instances of OrderSoupIntentHandler for iOS
*/

import Intents
import SoupKit

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        print("Main intent handler: ************************ ")
        guard intent is OrderSoupIntent else {
            fatalError("Unhandled intent type: \(intent)")
        }
        print("Wonderful star: ***********************")
        return OrderSoupIntentHandler()
    }
}

