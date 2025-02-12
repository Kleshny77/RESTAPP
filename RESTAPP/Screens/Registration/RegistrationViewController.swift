//
//  RegistrationViewController.swift
//  RESTAPP
//
//  Created by Artem Samsonov on 12.02.2025.
//

import UIKit

class RegistrationViewController: UIViewController {
    private let logoImageView = UIImageView(image: UIImage(named: "logo"))
    private let loginField = UITextField()
    private let passwordField = UITextField()
    private let registerButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        loginField.placeholder = "Логин"
        passwordField.placeholder = "Пароль"
        registerButton.setTitle("Далее", for: .normal)
        registerButton.backgroundColor = .systemBlue
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [loginField, passwordField, registerButton])
        stack.axis = .vertical
        stack.spacing = 10
        view.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }

    @objc private func registerTapped() {
        let mainVC = MainViewController()
        navigationController?.pushViewController(mainVC, animated: true)
    }
}
