/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A DataManager subclass that persists the active menu items.
*/

import Foundation
import Intents
import os.log

public typealias SoupMenu = Set<MenuItem>

public class SoupMenuManager: DataManager<Set<MenuItem>> {
    
    private static let defaultMenu: SoupMenu = [
        MenuItem(itemName: "Chicken Noodle Soup",
                 shortcutNameKey: "CHICKEN_NOODLE_SOUP",
                 price: 4.55, iconImageName: "chicken_noodle_soup",
                 isAvailable: true,
                 isDailySpecial: true),
        MenuItem(itemName: "Clam Chowder",
                 shortcutNameKey: "CLAM_CHOWDER",
                 price: 3.75,
                 iconImageName: "clam_chowder",
                 isAvailable: true,
                 isDailySpecial: false),
        MenuItem(itemName: "Tomato Soup",
                 shortcutNameKey: "TOMATO_SOUP",
                 price: 2.95,
                 iconImageName: "tomato_soup",
                 isAvailable: true,
                 isDailySpecial: false)
    ]
    
    public var orderManager: SoupOrderDataManager?
    
    public convenience init() {
        let storageInfo = UserDefaultsStorageDescriptor(key: UserDefaults.StorageKeys.soupMenu.rawValue,
                                                        keyPath: \UserDefaults.menu)
        self.init(storageDescriptor: storageInfo)
    }
    
    override func deployInitialData() {
        dataAccessQueue.sync {
            managedData = SoupMenuManager.defaultMenu
        }
        
        updateShortcuts()
    }
}

/// Public API for clients of `SoupMenuManager`
extension SoupMenuManager {
    
    public var availableItems: [MenuItem] {
        return dataAccessQueue.sync {
            return managedData.filter { $0.isAvailable == true }.sortedByName()
        }
    }
    
    public var availableDailySpecialItems: [MenuItem] {
        return dataAccessQueue.sync {
            return managedData.filter { $0.isDailySpecial == true && $0.isAvailable == true }.sortedByName()
        }
    }
    
    public var dailySpecialItems: [MenuItem] {
        return dataAccessQueue.sync {
            return managedData.filter { $0.isDailySpecial == true }.sortedByName()
        }
    }
    
    public var regularItems: [MenuItem] {
        return dataAccessQueue.sync {
            return managedData.filter { $0.isDailySpecial == false }.sortedByName()
        }
    }
    
    public var availableRegularItems: [MenuItem] {
        return dataAccessQueue.sync {
            return managedData.filter { $0.isDailySpecial == false && $0.isAvailable == true }.sortedByName()
        }
    }
    
    public func replaceMenuItem(_ previousMenuItem: MenuItem, with menuItem: MenuItem) {
        dataAccessQueue.sync {
            managedData.remove(previousMenuItem)
            managedData.insert(menuItem)
        }
        
        //  Access to UserDefaults is gated behind a seperate access queue.
        writeData()
        
        removeDonation(for: menuItem)
        updateShortcuts()
    }
    
    public func findItem(identifier: String) -> MenuItem? {
        return dataAccessQueue.sync {
            return managedData.first { $0.itemName == identifier }
        }
    }
}

/// Enables observation of `UserDefaults` for the `soupMenuStorage` key.
private extension UserDefaults {
    
    @objc var menu: Data? {
        return data(forKey: StorageKeys.soupMenu.rawValue)
    }
}

private extension Array where Element == MenuItem {
    func sortedByName() -> [MenuItem] {
        return sorted { (item1, item2) -> Bool in
            item1.itemName.localizedCaseInsensitiveCompare(item2.itemName) == .orderedAscending
        }
    }
}
