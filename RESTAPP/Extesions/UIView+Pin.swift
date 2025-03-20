//
//  UIView+Pin.swift
//  RESTAPP
//
//  Created by Артём on 12.02.2025.
//

import UIKit

// MARK: - Pin methods
/// Will throw exceptions when there is no common superview between constrained views.
extension UIView {
    enum ConstraintMode {
        case equal
        /// greaterOrEqual
        case grOE
        /// lessOrEqual
        case lsOE
    }
    
    enum PinSides {
        case top, bottom, left, right
    }
    
    // MARK: - Pin to UIView anchors
    
    @discardableResult
    func pinLeft(
        to otherView: UIView,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, leadingAnchor, otherView.leadingAnchor, constant: const)
    }
    
    @discardableResult
    func pinLeft(
        to anchor: NSLayoutXAxisAnchor,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, leadingAnchor, anchor, constant: const)
    }
    
    @discardableResult
    func pinRight(
        to otherView: UIView,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, trailingAnchor, otherView.trailingAnchor, constant: -const)
    }
    
    @discardableResult
    func pinRight(
        to anchor: NSLayoutXAxisAnchor,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, trailingAnchor, anchor, constant: -const)
    }
    
    @discardableResult
    func pinTop(
        to otherView: UIView,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, topAnchor, otherView.topAnchor, constant: const)
    }
    
    @discardableResult
    func pinTop(
        to anchor: NSLayoutYAxisAnchor,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, topAnchor, anchor, constant: const)
    }
    
    @discardableResult
    func pinBottom(
        to otherView: UIView,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, bottomAnchor, otherView.bottomAnchor, constant: -const)
    }
    
    @discardableResult
    func pinBottom(
        to anchor: NSLayoutYAxisAnchor,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, bottomAnchor, anchor, constant: -const)
    }
    
    // MARK: - Pin to UILayoutGuide anchors
    
    @discardableResult
    func pinLeft(
        to layoutGuide: UILayoutGuide,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, leadingAnchor, layoutGuide.leadingAnchor, constant: const)
    }
    
    @discardableResult
    func pinRight(
        to layoutGuide: UILayoutGuide,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, trailingAnchor, layoutGuide.trailingAnchor, constant: -const)
    }
    
    @discardableResult
    func pinTop(
        to layoutGuide: UILayoutGuide,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, topAnchor, layoutGuide.topAnchor, constant: const)
    }
    
    @discardableResult
    func pinBottom(
        to layoutGuide: UILayoutGuide,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, bottomAnchor, layoutGuide.bottomAnchor, constant: -const)
    }
    
    // Новый метод: привязка ко всем сторонам UILayoutGuide
    func pin(to layoutGuide: UILayoutGuide, _ const: Double = 0) {
        pinTop(to: layoutGuide, const)
        pinBottom(to: layoutGuide, const)
        pinLeft(to: layoutGuide, const)
        pinRight(to: layoutGuide, const)
    }
    
    // MARK: - Pin center
    
    func pinCenter(to otherView: UIView) {
        pinConstraint(mode: .equal, centerXAnchor, otherView.centerXAnchor)
        pinConstraint(mode: .equal, centerYAnchor, otherView.centerYAnchor)
    }
    
    @discardableResult
    func pinCenterX(
        to otherView: UIView,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, centerXAnchor, otherView.centerXAnchor, constant: const)
    }
    
    @discardableResult
    func pinCenterX(
        to anchor: NSLayoutXAxisAnchor,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, centerXAnchor, anchor, constant: const)
    }
    
    @discardableResult
    func pinCenterY(
        to otherView: UIView,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, centerYAnchor, otherView.centerYAnchor, constant: const)
    }
    
    @discardableResult
    func pinCenterY(
        to anchor: NSLayoutYAxisAnchor,
        _ const: Double = 0,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinConstraint(mode: mode, centerYAnchor, anchor, constant: const)
    }
    
    // MARK: - Pin width and height
    
    @discardableResult
    func pinWidth(
        to otherView: UIView,
        _ mult: Double = 1,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinDimension(mode: mode, widthAnchor, otherView.widthAnchor, multiplier: mult)
    }
    
    @discardableResult
    func pinWidth(
        to anchor: NSLayoutDimension,
        _ mult: Double = 1,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinDimension(mode: mode, widthAnchor, anchor, multiplier: mult)
    }
    
    @discardableResult
    func setWidth(mode: ConstraintMode = .equal, _ const: Double) -> NSLayoutConstraint {
        return pinDimension(mode: mode, widthAnchor, constant: const)
    }
    
    @discardableResult
    func pinHeight(
        to otherView: UIView,
        _ mult: Double = 1,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinDimension(mode: mode, heightAnchor, otherView.heightAnchor, multiplier: mult)
    }
    
    @discardableResult
    func pinHeight(
        to dimension: NSLayoutDimension,
        _ mult: Double = 1,
        _ mode: ConstraintMode = .equal
    ) -> NSLayoutConstraint {
        return pinDimension(mode: mode, heightAnchor, dimension, multiplier: mult)
    }
    
    @discardableResult
    func setHeight(mode: ConstraintMode = .equal, _ const: Double) -> NSLayoutConstraint {
        return pinDimension(mode: mode, heightAnchor, constant: const)
    }
    
    // MARK: - Pin Horizontal & Vertical
    
    func pinHorizontal(
        to otherView: UIView,
        _ const: Double = 0,
        mode: ConstraintMode = .equal
    ) {
        pinLeft(to: otherView, const, mode)
        pinRight(to: otherView, const, mode)
    }
    
    func pinVertical(
        to otherView: UIView,
        _ const: Double = 0,
        mode: ConstraintMode = .equal
    ) {
        pinTop(to: otherView, const, mode)
        pinBottom(to: otherView, const, mode)
    }
    
    func pin(to otherView: UIView, _ const: Double = 0) {
        pinVertical(to: otherView, const)
        pinHorizontal(to: otherView, const)
    }
    
    // MARK: - Private methods
    
    @discardableResult
    private func pinConstraint<Axis: AnyObject, AnyAnchor: NSLayoutAnchor<Axis>>(
        mode: ConstraintMode,
        _ firstAnchor: AnyAnchor,
        _ secondAnchor: AnyAnchor,
        constant: Double = 0
    ) -> NSLayoutConstraint {
        let const = CGFloat(constant)
        let result: NSLayoutConstraint
        translatesAutoresizingMaskIntoConstraints = false
        switch mode {
        case .equal:
            result = firstAnchor.constraint(equalTo: secondAnchor, constant: const)
        case .grOE:
            result = firstAnchor.constraint(greaterThanOrEqualTo: secondAnchor, constant: const)
        case .lsOE:
            result = firstAnchor.constraint(lessThanOrEqualTo: secondAnchor, constant: const)
        }
        result.isActive = true
        return result
    }
    
    @discardableResult
    private func pinDimension(
        mode: ConstraintMode,
        _ firstDimension: NSLayoutDimension,
        _ secondDimension: NSLayoutDimension,
        multiplier: Double = 1
    ) -> NSLayoutConstraint {
        let mult = CGFloat(multiplier)
        let result: NSLayoutConstraint
        translatesAutoresizingMaskIntoConstraints = false
        switch mode {
        case .equal:
            result = firstDimension.constraint(equalTo: secondDimension, multiplier: mult)
        case .grOE:
            result = firstDimension.constraint(greaterThanOrEqualTo: secondDimension, multiplier: mult)
        case .lsOE:
            result = firstDimension.constraint(lessThanOrEqualTo: secondDimension, multiplier: mult)
        }
        result.isActive = true
        return result
    }
    
    @discardableResult
    private func pinDimension(
        mode: ConstraintMode,
        _ dimension: NSLayoutDimension,
        constant: Double
    ) -> NSLayoutConstraint {
        let const = CGFloat(constant)
        let result: NSLayoutConstraint
        translatesAutoresizingMaskIntoConstraints = false
        switch mode {
        case .equal:
            result = dimension.constraint(equalToConstant: const)
        case .grOE:
            result = dimension.constraint(greaterThanOrEqualToConstant: const)
        case .lsOE:
            result = dimension.constraint(lessThanOrEqualToConstant: const)
        }
        result.isActive = true
        return result
    }
}
