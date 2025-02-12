//
//  Constants.swift
//  RESTAPP
//
//  Created by Artem Samsonov on 12.02.2025.
//

import Foundation

enum Constants {
    // MARK: - UIColorHex Parsing
    static let prefix: String = "#"
    static let minRgb: UInt64 = 0
    static let shiftRed: UInt64 = 16
    static let shiftGreen: UInt64 = 8
    static let mask: UInt64 = 0xFF
    static let divisor: CGFloat = 255.0
    static let maxAlpha: CGFloat = 1
    static let minAlpha: CGFloat = 0
}
