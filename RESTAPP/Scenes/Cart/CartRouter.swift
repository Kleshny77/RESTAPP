//
//  CartRouter.swift
//  RESTAPP
//
//  Created by Артём on 01.04.2025.
//

import UIKit

// MARK: - CartRoutingLogic

protocol CartRoutingLogic {}

// MARK: - CartDataPassing

protocol CartDataPassing {}

// MARK: - CartRouter

final class CartRouter: NSObject, CartRoutingLogic, CartDataPassing {
    
    // MARK: - Properties
    
    weak var viewController: UIViewController?
}
