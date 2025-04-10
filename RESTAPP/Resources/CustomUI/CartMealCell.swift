//
//  CartMealCell.swift
//  RESTAPP
//
//  Created by Артём on 28.03.2025.
//

import UIKit

// MARK: - CartItemCell
final class CartMealCell: UITableViewCell {
    
    static let reuseId = "CartMealCell"
    
    // MARK: – Callbacks
    var onIncrease: (() -> Void)?
    var onDecrease: (() -> Void)?
    var onTap     : (() -> Void)?
    
    // MARK: – UI
    private let mealImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode      = .scaleAspectFill
        iv.clipsToBounds    = true
        iv.layer.cornerRadius = 8
        return iv
    }()
    private let nameLabel = UILabel()
    private let weightLabel = UILabel()
    private let countLabel  = UILabel()
    
    private let minusButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("−", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .highlighted)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        return b
    }()
    private let plusButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("+", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .highlighted)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        return b
    }()
    
    private let counterContainer = UIView()
    
    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font      = .boldSystemFont(ofSize: 14)
        l.textColor = .black
        l.textAlignment = .right
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        return l
    }()
    
    // MARK: – Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(handleTap))
        tap.cancelsTouchesInView = false
        tap.delegate = self               // ← delegate задаём здесь
        contentView.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: – Configure
    func configure(with vm: CartItemViewModel) {
        nameLabel.text   = vm.name
        weightLabel.text = vm.weightText
        countLabel.text  = "\(vm.count)"
        priceLabel.text  = vm.priceText
        
        Task {
            if let url = vm.imageURL {
                await mealImageView.loadImageAsync(from: url)
            } else {
                mealImageView.image = UIImage(named: "placeholder")
            }
        }
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                    shouldReceive touch: UITouch) -> Bool {
        
        if touch.view === minusButton || touch.view === plusButton ||
            touch.view?.isDescendant(of: counterContainer) == true {
            return false
        }
        return true
    }
    
    func update(count: Int, priceText: String) {
        countLabel.text = "\(count)"
        priceLabel.text = priceText
    }
    
    override func setHighlighted(_ highlighted: Bool,
                                 animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            let scale: CGFloat = highlighted ? 0.95 : 1.0
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.alpha     = highlighted ? 0.9  : 1.0   // ← было 0.8
        }
    }
    
    // MARK: – Private UI
    private func buildUI() {
        nameLabel.font          = .systemFont(ofSize: 14)
        weightLabel.font        = .systemFont(ofSize: 12, weight: .medium)
        weightLabel.textColor   = .gray
        countLabel.font         = .systemFont(ofSize: 14)
        countLabel.textAlignment = .center
        
        counterContainer.backgroundColor = .systemGray6
        counterContainer.layer.cornerRadius = 18
        
        let countStack = UIStackView(arrangedSubviews: [minusButton, countLabel, plusButton])
        countStack.axis = .horizontal
        countStack.spacing = 8
        countStack.alignment = .center
        countStack.isLayoutMarginsRelativeArrangement = true
        countStack.layoutMargins = .init(top: -1, left: 7, bottom: -1, right: 7)
        
        counterContainer.addSubview(countStack)
        countStack.pin(to: counterContainer)
        
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 12
        
        [mealImageView, counterContainer, priceLabel,
         nameLabel, weightLabel]
            .forEach { contentView.addSubview($0) }
        
        mealImageView.pinTop(to: contentView, 8)
        mealImageView.pinLeft(to: contentView, 5)
        mealImageView.pinBottom(to: contentView)
        mealImageView.setWidth(75)
        mealImageView.pinHeight(to: mealImageView.widthAnchor)
        
        counterContainer.pinLeft(to: mealImageView.trailingAnchor, 12)
        counterContainer.pinBottom(to: mealImageView)
        
        priceLabel.pinRight(to: contentView, 6)
        priceLabel.pinCenterY(to: counterContainer.centerYAnchor)
        
        nameLabel.pinTop(to: mealImageView)
        nameLabel.pinLeft(to: counterContainer.leadingAnchor)
        nameLabel.pinRight(to: priceLabel.leadingAnchor, 12)
        
        weightLabel.pinTop(to: nameLabel.bottomAnchor, 4)
        weightLabel.pinLeft(to: nameLabel)
        
        minusButton.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        plusButton .addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)
    }
    
    // MARK: – Actions
    @objc private func decreaseTapped() { onDecrease?() }
    @objc private func increaseTapped() { onIncrease?() }
    @objc private func handleTap()      { onTap?() }
}

