//
//  UIColor+Hex.swift
//  RESTAPP
//
//  Created by Artem Samsonov on 12.02.2025.
//

import UIKit

// MARK: - UIColor Extension
extension UIColor {
    // MARK: Initializers
    convenience init?(hex: String) {
        // MARK: Sanitize input
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix(Constants.prefix) {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        // MARK: Parse hex value
        var rgb: UInt64 = Constants.minRgb
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        // MARK: Extract RGB components
        let red = CGFloat((rgb >> Constants.shiftRed) & Constants.mask) / Constants.divisor
        let green = CGFloat((rgb >> Constants.shiftGreen) & Constants.mask) / Constants.divisor
        let blue = CGFloat(rgb & Constants.mask) / Constants.divisor
        
        // MARK: Initialize UIColor
        self.init(red: red, green: green, blue: blue, alpha: Constants.maxAlpha)
    }
}
