// CartMealCell.swift

import UIKit

// MARK: - CartItemCell
final class CartMealCell: UITableViewCell {
    
    static let reuseId = "CartMealCell"
    
    // MARK: Callbacks
    var onIncrease: (() -> Void)?
    var onDecrease: (() -> Void)?
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
            super.setHighlighted(highlighted, animated: animated)
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: [.curveEaseOut, .allowUserInteraction]) {
                let scale: CGFloat = highlighted ? 0.95 : 1.0
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
                self.alpha     = highlighted ? 0.8  : 1.0
            }
        }
    
    // MARK: UI Elements
    private let mealImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        return l
    }()
    
    private let weightLabel: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .gray
        return l
    }()
    
    private let countLabel: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 14)
        l.textAlignment = .center
        return l
    }()
    
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
    
    private let countStack: UIStackView = {
        let st = UIStackView()
        st.axis      = .horizontal
        st.spacing   = 8
        st.alignment = .center
        st.isLayoutMarginsRelativeArrangement = true
        st.layoutMargins = .init(top: -1, left: 7, bottom: -1, right: 7)
        return st
    }()
    
    private let counterContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGray6
        v.layer.cornerRadius = 18
        return v
    }()
    
    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font      = .boldSystemFont(ofSize: 14)
        l.textColor = .black
        l.textAlignment = .right
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        return l
    }()
    
    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
        selectionStyle = .none
    }
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        [nameLabel, weightLabel, countLabel, priceLabel].forEach { $0.text = nil }
        mealImageView.image = nil
    }
    
    // MARK: Configure
    func configure(with vm: CartItemViewModel) {
        nameLabel.text   = vm.name
        weightLabel.text = vm.weightText
        countLabel.text  = "\(vm.count)"
        priceLabel.text  = vm.priceText
        Task { await mealImageView.loadImageAsync(from: vm.imageURL) }
    }
    
    func update(count: Int, priceText: String) {
        countLabel.text = "\(count)"
        priceLabel.text = priceText
    }
    
    // MARK: Build UI
    private func buildUI() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = false
        
        contentView.addSubview(mealImageView)
        mealImageView.pinTop(to: contentView, 8)
        mealImageView.pinLeft(to: contentView, 5)
        mealImageView.pinBottom(to: contentView)
        mealImageView.setWidth(75)
        mealImageView.pinHeight(to: mealImageView.widthAnchor)
        
        [minusButton, countLabel, plusButton].forEach(countStack.addArrangedSubview)
        counterContainer.addSubview(countStack)
        countStack.pin(to: counterContainer)
        contentView.addSubview(counterContainer)
        counterContainer.pinLeft(to: mealImageView.trailingAnchor, 12)
        counterContainer.pinBottom(to: mealImageView)
        
        contentView.addSubview(priceLabel)
        priceLabel.pinRight(to: contentView, 6)
        priceLabel.pinCenterY(to: counterContainer.centerYAnchor)
        
        contentView.addSubview(nameLabel)
        nameLabel.pinTop(to: mealImageView)
        nameLabel.pinLeft(to: counterContainer.leadingAnchor)
        nameLabel.pinRight(to: priceLabel.leadingAnchor, 12)
        
        contentView.addSubview(weightLabel)
        weightLabel.pinTop(to: nameLabel.bottomAnchor, 4)
        weightLabel.pinLeft(to: nameLabel)
        
        minusButton.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        plusButton .addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)
    }
    
    @objc private func decreaseTapped() { onDecrease?() }
    @objc private func increaseTapped() { onIncrease?() }
}
