//
//  CartViewController.swift
//  RESTAPP
//
//  Created by Артём on 01.04.2025.
//

import UIKit

// MARK: - CartDisplayLogic

protocol CartDisplayLogic: AnyObject {
    func displayCart(viewModel: Cart.Load.ViewModel)
}

// MARK: - CartViewController

final class CartViewController: UIViewController, CartDisplayLogic {
    
    // MARK: - Properties
    
    var interactor: CartBusinessLogic?
    var router: (NSObjectProtocol & CartRoutingLogic)?
    
    // MARK: - UI Elements
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        return sv
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Оплатить", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        interactor?.loadCart(request: .init())
    }
    
    // MARK: - UI Configuration
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        configureStackView()
        configureTotalLabel()
        configurePayButton()
    }
    
    private func configureStackView() {
        view.addSubview(stackView)
        stackView.pin(to: view.safeAreaLayoutGuide, 16)
    }
    
    private func configureTotalLabel() {
        view.addSubview(totalLabel)
        totalLabel.pinTop(to: stackView.bottomAnchor, 20)
        totalLabel.pinLeft(to: view, 20)
    }
    
    private func configurePayButton() {
        view.addSubview(payButton)
        payButton.pinLeft(to: view, 20)
        payButton.pinRight(to: view, 20)
        payButton.pinBottom(to: view.safeAreaLayoutGuide, 20)
        payButton.setHeight(mode: .equal, 50)
    }
    
    // MARK: - Display Logic
    
    func displayCart(viewModel: Cart.Load.ViewModel) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in viewModel.items {
            let row = createRow(for: item)
            stackView.addArrangedSubview(row)
        }
        totalLabel.text = viewModel.totalText
    }
    
    // MARK: - Helper Methods
    
    private func createRow(for item: CartItemViewModel) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .equalSpacing
        
        let nameLabel = UILabel()
        nameLabel.text = item.name
        
        let countLabel = UILabel()
        countLabel.text = item.countText
        
        let priceLabel = UILabel()
        priceLabel.text = item.totalPriceText
        priceLabel.textColor = .systemGreen
        
        row.addArrangedSubview(nameLabel)
        row.addArrangedSubview(countLabel)
        row.addArrangedSubview(priceLabel)
        
        return row
    }
}
