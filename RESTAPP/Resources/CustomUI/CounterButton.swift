//
//  CounterButton.swift
//  RESTAPP
//
//  Created by Артём on 29.03.2025.
//

import UIKit

final class CounterButton: UIView {
    
    // MARK: - Properties
    var onIncrease: (() -> Void)?
    var onDecrease: (() -> Void)?
    
    private var count: Int = 0
    private var price: Int = 0
    private var widthConstraint: NSLayoutConstraint?
    
    // MARK: - UI Elements
    private let priceButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    private let counterContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 8
        view.isHidden = true
        view.alpha = 0
        return view
    }()
    
    private let minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(priceButton)
        priceButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceButton.topAnchor.constraint(equalTo: topAnchor),
            priceButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            priceButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            priceButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        addSubview(counterContainer)
        counterContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            counterContainer.topAnchor.constraint(equalTo: topAnchor),
            counterContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            counterContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            counterContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        let stack = UIStackView(arrangedSubviews: [minusButton, countLabel, plusButton])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 16
        
        counterContainer.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: counterContainer.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: counterContainer.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: counterContainer.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: counterContainer.bottomAnchor, constant: -8)
        ])
        
        widthConstraint = widthAnchor.constraint(equalToConstant: 120)
        widthConstraint?.isActive = true
    }
    
    private func setupActions() {
        priceButton.addTarget(self, action: #selector(priceButtonTapped), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(decreaseCount), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(increaseCount), for: .touchUpInside)
    }
    
    // MARK: - Public Methods
    func configure(price: Int) {
        self.price = price
        priceButton.setTitle("\(price) ₽", for: .normal)
    }
    
    func updateCount(_ newCount: Int) {
        count = newCount
        if newCount > 0 {
            showCounter(count: newCount)
        } else {
            showPriceButton()
        }
    }
    
    // MARK: - Private Methods
    private func showCounter(count: Int, animated: Bool = true) {
        counterContainer.isHidden = false
        countLabel.text = "\(count)"
        
        if animated {
            UIView.animate(withDuration: 0.1, animations: {
                self.priceButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    self.priceButton.alpha = 0
                    self.counterContainer.alpha = 1
                    self.priceButton.transform = .identity
                })
            }
        } else {
            priceButton.alpha = 0
            counterContainer.alpha = 1
        }
    }
    
    private func showPriceButton(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.15, animations: {
                self.counterContainer.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self.priceButton.alpha = 1
                    self.counterContainer.alpha = 0
                    self.counterContainer.transform = .identity
                }) { _ in
                    self.counterContainer.isHidden = true
                }
            }
        } else {
            priceButton.alpha = 1
            counterContainer.alpha = 0
            counterContainer.isHidden = true
        }
    }
    
    // MARK: - Button Actions
    @objc private func priceButtonTapped() {
        increaseCount()
    }
    
    @objc private func increaseCount() {
        onIncrease?()
    }
    
    @objc private func decreaseCount() {
        onDecrease?()
    }
    
    // MARK: - Button Highlight Animations
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animateButtonPress(pressed: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateButtonPress(pressed: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateButtonPress(pressed: false)
    }
    
    private func animateButtonPress(pressed: Bool) {
        let transform: CGAffineTransform = pressed ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
        let alpha: CGFloat = pressed ? 0.9 : 1.0
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
            self.transform = transform
            self.alpha = alpha
        }
    }
}
