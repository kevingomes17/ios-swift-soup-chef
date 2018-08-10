/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A utility for requesting localized strings for the user interface.
*/

import Foundation

/// A type with a localized string that will load the appropriate localized value for a shortcut.
protocol LocalizableShortcutString {
    
    /// - Returns: A string key for the localized value.
    var shortcutLocalizationKey: String { get }
}

/// A type with a localized currency string that is appropiate to display in UI.
protocol LocalizableCurrency {
    
    /// - Returns: A string that displays a locale sensitive currency format.
    var localizedCurrencyValue: String { get }
}
