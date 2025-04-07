import UIKit

final class CounterView: UIView {
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)
    private let countLabel = UILabel()
    
    var count: Int = 0 {
        didSet {
            countLabel.text = "\(count)"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(hex: "FF9700")
        layer.cornerRadius = 8
        
        // Настройка кнопок
        [minusButton, plusButton].forEach {
            $0.tintColor = .white
            $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        }
        
        minusButton.setTitle("−", for: .normal)
        plusButton.setTitle("+", for: .normal)
        
        // Настройка лейбла
        countLabel.textColor = .white
        countLabel.font = .systemFont(ofSize: 16, weight: .medium)
        countLabel.textAlignment = .center
        countLabel.text = "0"
        
        // Добавление и расположение элементов
        [minusButton, countLabel, plusButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            minusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            minusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 44),
            
            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            plusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 44),
            
            countLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            countLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor),
            countLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor)
        ])
    }
} 