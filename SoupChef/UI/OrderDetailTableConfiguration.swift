/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This struct encapsulates the configuration of the `UITableView` in `OrderDetailViewController`.
*/

import Foundation
import SoupKit

struct OrderDetailTableConfiguration {
    
    enum OrderType {
        case new, historical
    }
    
    enum SectionType: String {
        case price = "Price"
        case quantity = "Quantity"
        case options = "Options"
        case total = "Total"
    }
    
    enum ReuseIdentifiers: String {
        case basic = "Basic Cell"
        case quantity = "Quantity Cell"
    }
    
    public let orderType: OrderType
    
    init(orderType: OrderType) {
        self.orderType = orderType
    }
    
    typealias SectionModel = (type: SectionType, rowCount: Int, cellReuseIdentifier: String)
    
    private static let newOrderSectionModel: [SectionModel] = [SectionModel(type: .price,
                                                                            rowCount: 1,
                                                                            cellReuseIdentifier: ReuseIdentifiers.basic.rawValue),
                                                               SectionModel(type: .quantity,
                                                                            rowCount: 1,
                                                                            cellReuseIdentifier: ReuseIdentifiers.quantity.rawValue),
                                                               SectionModel(type: .options,
                                                                            rowCount: Order.MenuItemOption.all.count,
                                                                            cellReuseIdentifier: ReuseIdentifiers.basic.rawValue),
                                                               SectionModel(type: .total,
                                                                            rowCount: 1,
                                                                            cellReuseIdentifier: ReuseIdentifiers.basic.rawValue)]
    
    private static let historicalOrderSectionModel: [SectionModel] = [SectionModel(type: .quantity,
                                                                                   rowCount: 1,
                                                                                   cellReuseIdentifier: ReuseIdentifiers.quantity.rawValue),
                                                                      SectionModel(type: .options,
                                                                                   rowCount: Order.MenuItemOption.all.count,
                                                                                   cellReuseIdentifier: ReuseIdentifiers.basic.rawValue),
                                                                      SectionModel(type: .total,
                                                                                   rowCount: 1,
                                                                                   cellReuseIdentifier: ReuseIdentifiers.basic.rawValue)]
    
    var sections: [SectionModel] {
        switch orderType {
            case .new: return OrderDetailTableConfiguration.newOrderSectionModel
            case .historical: return OrderDetailTableConfiguration.historicalOrderSectionModel
        }
    }
}
