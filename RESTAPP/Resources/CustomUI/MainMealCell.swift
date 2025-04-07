//
//  MealCell.swift
//  RESTAPP
//

import UIKit
import SDWebImage

// MARK: – MealCell
final class MainMealCell: UICollectionViewCell {

    static let reuseID = "MainMealCell"
    override var isHighlighted: Bool {
        didSet {
            animateHighlight(isHighlighted)
        }
    }

    private func animateHighlight(_ isPressed: Bool) {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveEaseOut, .allowUserInteraction],
                       animations: {
            self.transform = isPressed ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
            self.alpha = isPressed ? 0.8 : 1.0
        })
    }
    // MARK: UI‑элементы

    /// Фото блюда
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode       = .scaleAspectFill
        iv.clipsToBounds     = true
        iv.layer.cornerRadius = 12
        return iv
    }()

    /// Название (до 2-х строк, остривается …)
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font           = .systemFont(ofSize: 14, weight: .regular)
        l.numberOfLines  = 2
        l.lineBreakMode  = .byTruncatingTail
        return l
    }()

    /// Вес (смотрим, ровно 1 строка ли занято, иначе скрываем)
    private let weightLabel: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .gray
        return l
    }()

    /// Кнопка "цена ₽ +"
    private let priceButton: HighlightButton = {
        let b = HighlightButton(type: .custom)
        b.backgroundColor   = UIColor(hex: "F2F2F2")
        b.layer.cornerRadius = 14
        return b
    }()

    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .systemPink
        l.isUserInteractionEnabled = false
        return l
    }()
    private let plusIcon: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let iv  = UIImageView(image: UIImage(systemName: "plus", withConfiguration: cfg))
        iv.tintColor = .systemPink
        iv.isUserInteractionEnabled = false
        return iv
    }()

    /// Контейнер "счётчика"
    private let counterContainer: UIView = {
        let v = UIView()
        v.backgroundColor   = .systemGray6
        v.layer.cornerRadius = 14
        v.isHidden          = true
        return v
    }()
    private let minusButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("−", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.setTitleColor(.black.withAlphaComponent(0.5), for: .highlighted)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        return b
    }()
    private let countLabel: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 13, weight: .medium)
        l.textAlignment = .center
        return l
    }()
    private let plusCounterButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("+", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.setTitleColor(.black.withAlphaComponent(0.5), for: .highlighted)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        return b
    }()
    private lazy var countStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [minusButton, countLabel, plusCounterButton])
        st.axis      = .horizontal
        st.spacing   = 8
        st.alignment = .center
        st.isLayoutMarginsRelativeArrangement = true
        st.layoutMargins = .init(top: 1, left: 6, bottom: 2, right: 1)
        return st
    }()

    // MARK: – Model
    private var meal: Meal?

    
    // MARK: – Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureImage()
        configureName()
        configureWeight()
        configurePriceButton()
        configureCounter()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: – Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        [nameLabel, weightLabel, priceLabel, countLabel].forEach { $0.text = nil }
        imageView.image = nil
        meal = nil
        // сбросить режим
        priceButton.isHidden        = false
        counterContainer.isHidden   = true
    }

    // MARK: – Public API
    func configure(with meal: Meal) {
        self.meal = meal
        nameLabel.text    = meal.name
        weightLabel.text  = "\(meal.weight) г"
        priceLabel.text   = "\(meal.price) ₽"
        if let imageURLString = meal.imageURL {
            imageView.sd_setImage(with: URL(string: imageURLString),
                                placeholderImage: UIImage(named: "placeholder"))
        } else {
            imageView.image = UIImage(named: "placeholder")
        }

        // скрывать вес, если название занимает две строки
        nameLabel.preferredMaxLayoutWidth = contentView.bounds.width - 6
        layoutIfNeeded()
        weightLabel.isHidden = nameLabel.requiredLines > 1

        // по количеству в корзине переключаем вид
        let currentCount = CartService.shared
            .getAllItems()
            .first { $0.meal == meal }?
            .count ?? 0
        
        if currentCount > 0 {
            showCounter(count: currentCount)
        } else {
            showPriceButton()
        }
    }

    // MARK: – UI‑helpers

    private func configureImage() {
        contentView.addSubview(imageView)
        imageView.pinTop(to: contentView)
        imageView.pinHorizontal(to: contentView)
        imageView.pinHeight(to: imageView.widthAnchor)
    }

    private func configureName() {
        contentView.addSubview(nameLabel)
        nameLabel.pinTop(to: imageView.bottomAnchor, 5)
        nameLabel.pinLeft(to: contentView, 5)
        nameLabel.pinRight(to: contentView, 5)
    }

    private func configureWeight() {
        contentView.addSubview(weightLabel)
        weightLabel.pinTop(to: nameLabel.bottomAnchor, 4)
        weightLabel.pinLeft(to: contentView, 5)
        weightLabel.pinRight(to: contentView, 5)
    }

    private func configurePriceButton() {
        // собираем "капсулу"
        let h = UIStackView(arrangedSubviews: [priceLabel, plusIcon])
        h.axis      = .horizontal
        h.alignment = .center
        h.spacing   = 5
        h.isLayoutMarginsRelativeArrangement = true
        h.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        h.isUserInteractionEnabled = false
        priceButton.setHeight(mode: .equal, 30)

        priceButton.addSubview(h)
        h.pin(to: priceButton)

        contentView.addSubview(priceButton)
        priceButton.pinLeft(to: contentView)
        priceButton.pinBottom(to: contentView)
        priceButton.pinRight(to: contentView, 65)
        // высота капсулы по intrinsic‑content

        // action
        priceButton.addTarget(self,
                              action: #selector(plusTapped),
                              for: .touchUpInside)
    }

    private func configureCounter() {
        // собираем стек
        counterContainer.addSubview(countStack)
        countStack.pin(to: counterContainer)

        contentView.addSubview(counterContainer)
        counterContainer.pinLeft(to: contentView)
        counterContainer.pinBottom(to: contentView)

        // минус
        minusButton.addTarget(self,
                              action: #selector(minusTapped),
                              for: .touchUpInside)
        // + из счётчика
        plusCounterButton.addTarget(self,
                                    action: #selector(plusTapped),
                                    for: .touchUpInside)
    }

    private func showCounter(count: Int) {
        countLabel.text = "\(count)"
        priceButton.isHidden      = true
        counterContainer.isHidden = false
        UIView.transition(with: counterContainer,
                          duration: 0.3,
                          options: [.transitionCrossDissolve, .allowUserInteraction],
                          animations: nil)
    }

    private func showPriceButton() {
        priceButton.isHidden      = false
        counterContainer.isHidden = true
        UIView.transition(with: priceButton,
                          duration: 0.3,
                          options: [.transitionCrossDissolve, .allowUserInteraction],
                          animations: nil)
    }

    // MARK: – Actions
    
    func updateCounter(to count: Int) {
        countLabel.text = "\(count)"
        priceButton.isHidden      = true
        counterContainer.isHidden = false
    }
    func resetToPriceButton() {
        priceButton.isHidden      = false
        counterContainer.isHidden = true
    }

    @objc private func plusTapped() {
        guard let meal else { return }
        CartService.shared.add(meal: meal)
        let newCount = CartService.shared.getAllItems().first { $0.meal == meal }!.count

        if counterContainer.isHidden {
          // первый раз: сразу показать счётчик и анимировать переход
          showCounter(count: newCount)
        } else {
          // последующие клики: просто обновляем число без анимации
          countLabel.text = "\(newCount)"
        }
    }
    @objc private func minusTapped() {
        guard let meal else { return }
        CartService.shared.remove(meal: meal)
        let newCount = CartService.shared.getAllItems().first { $0.meal == meal }?.count ?? 0

        if newCount > 0 {
          // просто обновляем
          countLabel.text = "\(newCount)"
        } else {
          // последний элемент — анимированно возвращаем кнопку «цена+»
          showPriceButton()
        }
    }
}

// вычисление строк UILabel
private extension UILabel {
    var requiredLines: Int {
        guard let txt = text, let fnt = font else { return 0 }
        let maxSize = CGSize(width: preferredMaxLayoutWidth,
                             height: .greatestFiniteMagnitude)
        let rect = (txt as NSString)
            .boundingRect(with: maxSize,
                          options: [.usesLineFragmentOrigin, .usesFontLeading],
                          attributes: [.font: fnt],
                          context: nil)
        return Int(ceil(rect.height / fnt.lineHeight))
    }
}

final class HighlightButton: UIButton {

    /// финальное «утопленное» состояние
    private let pressedTransform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    private let pressedAlpha: CGFloat = 0.5

    override var isHighlighted: Bool {
        didSet { animateHighlight(isHighlighted) }
    }

    private func animateHighlight(_ pressed: Bool) {
        // отменяем возможную предыдущую
        layer.removeAllAnimations()

        if pressed {
            // ➡️ «вдавливаемся» – чуть быстрее и без пружинки
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseOut, .allowUserInteraction]) {
                self.alpha = self.pressedAlpha
                self.transform = self.pressedTransform
            }
        } else {
            // ⬅️ «отпрыгиваем» – чуть медленнее и c лёгкой пружинкой
            UIView.animate(withDuration: 0.45,
                           delay: 0,
                           usingSpringWithDamping: 0.85,
                           initialSpringVelocity: 0.3,
                           options: [.allowUserInteraction]) {
                self.alpha = 1.0
                self.transform = .identity
            }
        }
    }
}

