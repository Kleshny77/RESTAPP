//
//  SignUpController.swift
//  RESTAPP
//
//  Created by Артём on 20.03.2025.
//

import UIKit

// MARK: - Display Logic
protocol SignUpDisplayLogic: AnyObject {
    func displayRegistrationResult(_ viewModel: SignUp.Register.ViewModel)
    func displayStaticContent(viewModel: SignUp.StaticContent.ViewModel)
}

// MARK: - SignUpViewController
final class SignUpViewController: UIViewController, SignUpDisplayLogic {
    
    // MARK: - Properties
    var interactor: SignUpBusinessLogic?
    var router: (NSObjectProtocol & SignUpRoutingLogic & SignUpDataPassing)?
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentView = UIView()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 26, weight: .black)
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let fullNameHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "Full name"
        return label
    }()
    
    private let fullNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter your full name"
        tf.borderStyle = .roundedRect
        tf.textContentType = .name
        return tf
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
        tf.placeholder = "Create a password"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.textContentType = .newPassword
        tf.autocorrectionType = .no
        return tf
    }()
    
    private let confirmPasswordHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "Confirm password"
        return label
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm your password"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.textContentType = .newPassword
        tf.autocorrectionType = .no
        return tf
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
    init(interactor: SignUpBusinessLogic, router: (NSObjectProtocol & SignUpRoutingLogic & SignUpDataPassing)) {
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
        setupConstraints()
        setupKeyboardObservers()
        setupTapGesture()
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
        contentView.addSubview(fullNameTextField)
        contentView.addSubview(fullNameHeaderLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(emailHeaderLabel)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(passwordHeaderLabel)
        contentView.addSubview(confirmPasswordTextField)
        contentView.addSubview(confirmPasswordHeaderLabel)
        contentView.addSubview(signUpButton)
    }
    
    private func setupConstraints() {
        configureImage()
        configureTitle()
        configureDescription()
        configureFullName()
        configureEmail()
        configurePassword()
        configureConfirmPassword()
        configureSignUp()
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
    
    private func configureFullName() {
        fullNameTextField.pinTop(to: descriptionLabel.bottomAnchor, 50)
        fullNameTextField.pinHorizontal(to: contentView, 50)
        fullNameTextField.setHeight(40)
        fullNameHeaderLabel.pinBottom(to: fullNameTextField.topAnchor, 4)
        fullNameHeaderLabel.pinHorizontal(to: contentView, 50)
    }
    
    private func configureEmail() {
        emailTextField.pinTop(to: fullNameTextField.bottomAnchor, 40)
        emailTextField.pinHorizontal(to: contentView, 50)
        emailTextField.setHeight(40)
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
        passwordHeaderLabel.pinBottom(to: passwordTextField.topAnchor, 4)
        passwordHeaderLabel.pinHorizontal(to: contentView, 50)
    }
    
    private func configureConfirmPassword() {
        confirmPasswordTextField.pinTop(to: passwordTextField.bottomAnchor, 40)
        confirmPasswordTextField.pinHorizontal(to: contentView, 50)
        confirmPasswordTextField.setHeight(40)
        let toggleButton = UIButton(type: .system)
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        toggleButton.tintColor = .gray
        toggleButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        confirmPasswordTextField.rightView = toggleButton
        confirmPasswordTextField.rightViewMode = .always
        confirmPasswordHeaderLabel.pinBottom(to: confirmPasswordTextField.topAnchor, 4)
        confirmPasswordHeaderLabel.pinHorizontal(to: contentView, 50)
    }
    
    private func configureSignUp() {
        signUpButton.pinTop(to: confirmPasswordTextField.bottomAnchor, 20)
        signUpButton.pinHorizontal(to: contentView, 50)
        signUpButton.pinBottom(to: contentView, 50)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    @objc private func signUpButtonTapped() {
        let request = SignUp.Register.Request(
            fullName: fullNameTextField.text ?? "",
            email: emailTextField.text ?? "",
            password: passwordTextField.text ?? "",
            confirmPassword: confirmPasswordTextField.text ?? ""
        )
        guard isValidEmail(emailTextField.text ?? "") else {
            showAlert(title: "Ошибка", message: "Введите корректный email")
            return
        }
        interactor?.signUp(request: request)
    }
    
    @objc private func togglePasswordVisibility() {
        let shouldSecure = !passwordTextField.isSecureTextEntry
        let wasFirstResponder = passwordTextField.isFirstResponder
        
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
        
        passwordTextField.isSecureTextEntry = shouldSecure
        confirmPasswordTextField.isSecureTextEntry = shouldSecure
        
        let imageName = shouldSecure ? "eye.slash" : "eye"
        if let button = passwordTextField.rightView as? UIButton {
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
        if let button2 = confirmPasswordTextField.rightView as? UIButton {
            button2.setImage(UIImage(systemName: imageName), for: .normal)
        }
        
        if wasFirstResponder {
            DispatchQueue.main.async {
                self.passwordTextField.becomeFirstResponder()
            }
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = frame.height + 20
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Display Logic
    func displayRegistrationResult(_ viewModel: SignUp.Register.ViewModel) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: viewModel.isSuccess ? "Success" : "Error",
                message: viewModel.message,
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "ОК", style: .default) { [weak self] _ in
                self?.router?.routeToMain()
            }
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
    
    func displayStaticContent(viewModel: SignUp.StaticContent.ViewModel) {
        DispatchQueue.main.async {
            self.titleLabel.text = viewModel.title
            self.descriptionLabel.text = viewModel.description
            self.imageView.image = viewModel.picture
        }
    }
    
    // MARK: - Helpers
    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
