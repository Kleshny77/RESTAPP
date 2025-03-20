//
//  LoginViewController.swift
//  RESTAPP
//
//  Created by Артём on 20.03.2025.
//

import UIKit

// MARK: - LoginDisplayLogic

protocol LoginDisplayLogic: AnyObject {
    func displayLoginResult(_ viewModel: Login.Authenticate.ViewModel)
    func displayStaticContent(viewModel: Login.StaticContent.ViewModel)
}

// MARK: - LoginViewController

final class LoginViewController: UIViewController, LoginDisplayLogic {
    
    // MARK: - Properties
    
    var interactor: LoginBusinessLogic?
    var router: (NSObjectProtocol & LoginRoutingLogic & LoginDataPassing)?
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 26, weight: .black)
        label.textAlignment = .center
        return label
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let emailHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "Email"
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter your email"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.textContentType = .emailAddress
        tf.autocorrectionType = .no
        return tf
    }()
    
    private let passwordHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "Password"
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter your password"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "FF9700")
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "FF9700")
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Initializer
    
    init(interactor: LoginBusinessLogic, router: (NSObjectProtocol & LoginRoutingLogic & LoginDataPassing)) {
        self.interactor = interactor
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        interactor?.loadStaticContent()
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.width / 2
    }
    
    // MARK: - UI Configuration
    
    private func configureUI() {
        view.backgroundColor = UIColor(hex: "F9F9F9")
        setupScrollView()
        setupSubviews()
        configureImage()
        configureTitle()
        configureDescription()
        configureEmail()
        configureEmailHeader()
        configurePassword()
        configurePasswordHeader()
        configureButtons()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.pin(to: view.safeAreaLayoutGuide, 0)
        scrollView.addSubview(contentView)
        contentView.pin(to: scrollView.contentLayoutGuide, 0)
        contentView.pinWidth(to: scrollView.frameLayoutGuide.widthAnchor)
    }
    
    private func setupSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(emailHeaderLabel)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(passwordHeaderLabel)
        contentView.addSubview(signInButton)
        contentView.addSubview(signUpButton)
    }
    
    private func configureImage() {
        imageView.pinTop(to: contentView, 8)
        imageView.pinCenterX(to: contentView)
        imageView.setWidth(150)
        imageView.setHeight(150)
    }
    
    private func configureTitle() {
        titleLabel.pinTop(to: imageView.bottomAnchor, 20)
        titleLabel.pinHorizontal(to: contentView, 50)
    }
    
    private func configureDescription() {
        descriptionLabel.pinTop(to: titleLabel.bottomAnchor, 8)
        descriptionLabel.pinHorizontal(to: contentView, 50)
    }
    
    private func configureEmail() {
        emailTextField.pinTop(to: descriptionLabel.bottomAnchor, 50)
        emailTextField.pinHorizontal(to: contentView, 50)
        emailTextField.setHeight(40)
    }
    
    private func configureEmailHeader() {
        emailHeaderLabel.pinBottom(to: emailTextField.topAnchor, 4)
        emailHeaderLabel.pinHorizontal(to: contentView, 50)
    }
    
    private func configurePassword() {
        passwordTextField.pinTop(to: emailTextField.bottomAnchor, 40)
        passwordTextField.pinHorizontal(to: contentView, 50)
        passwordTextField.setHeight(40)
        let toggleButton = UIButton(type: .system)
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        toggleButton.tintColor = .gray
        toggleButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        passwordTextField.rightView = toggleButton
        passwordTextField.rightViewMode = .always
    }
    
    private func configurePasswordHeader() {
        passwordHeaderLabel.pinBottom(to: passwordTextField.topAnchor, 4)
        passwordHeaderLabel.pinHorizontal(to: contentView, 50)
    }
    
    private func configureButtons() {
        signInButton.pinTop(to: passwordTextField.bottomAnchor, 20)
        signInButton.pinHorizontal(to: contentView, 50)
        
        signUpButton.pinTop(to: signInButton.bottomAnchor, 20)
        signUpButton.pinBottom(to: contentView, 20)
        signUpButton.pinHorizontal(to: contentView, 50)
    }
    
    // MARK: - Actions
    
    @objc private func signInButtonTapped() {
        let request = Login.Authenticate.Request(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        interactor?.login(request: request)
    }
    
    @objc private func signUpButtonTapped() {
        router?.routeToSignUp()
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        if let button = passwordTextField.rightView as? UIButton {
            let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    // MARK: - Display Logic
    
    func displayLoginResult(_ viewModel: Login.Authenticate.ViewModel) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: viewModel.isSuccess ? "Успешно" : "Ошибка",
                                          message: viewModel.message,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default) { [weak self] _ in
                if viewModel.isSuccess {
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    self?.router?.routeToMain()
                }
            }
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
    
    func displayStaticContent(viewModel: Login.StaticContent.ViewModel) {
        DispatchQueue.main.async {
            self.titleLabel.text = viewModel.title
            self.descriptionLabel.text = viewModel.description
            self.imageView.image = viewModel.picture
        }
    }
}
