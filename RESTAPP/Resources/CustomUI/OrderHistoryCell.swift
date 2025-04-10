//
//  OrderHistoryCell.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

import UIKit

private let forty: CGFloat = 40

final class OrderHistoryCell: UITableViewCell {
    static let reuseId = "OrderHistoryCell"
    
    // MARK: - UI
    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        return l
    }()
    private let infoLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .darkGray
        return l
    }()
    private let imagesStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        return sv
    }()
    
    // MARK: — Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(dateLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(imagesStack)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        imagesStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            infoLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            infoLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            
            imagesStack.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8),
            imagesStack.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            imagesStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: — Configuration
    func configure(date: String, info: String, imageURLs: [URL]) {
        dateLabel.text = date
        infoLabel.text = info
        
        imagesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let extra = max(0, imageURLs.count - 5)
        let displayCount = extra > 0 ? 5 : imageURLs.count
        
        for i in 0..<displayCount {
            let iv = UIImageView()
            iv.layer.cornerRadius = 4
            iv.clipsToBounds      = true
            iv.contentMode        = .scaleAspectFill
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant:  forty).isActive = true
            iv.heightAnchor.constraint(equalToConstant:  forty).isActive = true
            imagesStack.addArrangedSubview(iv)
            
            Task {
                await iv.loadImageAsync(from: imageURLs[i].absoluteString)
            }
        }
        
        if extra > 0, let last = imagesStack.arrangedSubviews.last as? UIImageView {
            let overlay = UILabel()
            overlay.text = "+\(extra)"
            overlay.textColor = .white
            overlay.font = .systemFont(ofSize: 14, weight: .bold)
            overlay.textAlignment = .center
            overlay.backgroundColor = UIColor(white: 0, alpha: 0.5)
            overlay.translatesAutoresizingMaskIntoConstraints = false
            last.addSubview(overlay)
            NSLayoutConstraint.activate([
                overlay.leadingAnchor.constraint(equalTo: last.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: last.trailingAnchor),
                overlay.topAnchor.constraint(equalTo: last.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: last.bottomAnchor),
            ])
        }
    }
}
