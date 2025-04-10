//
//  ProfileViewController.swift
//  RESTAPP
//
//  Created by Артём on 30.04.2025.
//

import UIKit

// MARK: – Display Logic
protocol ProfileDisplayLogic: AnyObject {
    func displayProfile(viewModel: Profile.LoadProfile.ViewModel)
    func displayLogout(viewModel: Profile.Logout.ViewModel)
}

// MARK: – ProfileViewController
final class ProfileViewController: UIViewController {
    
    // MARK: – Dependencies
    private let interactor: ProfileBusinessLogic
    private let router: ProfileRoutingLogic
    
    // MARK: – State
    private var userName  = ""
    private var userEmail = ""
    private var orders: [OrderCellViewModel] = []
    
    // MARK: – UI
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.register(UITableViewCell.self,  forCellReuseIdentifier: "ProfileInfoCell")
        tv.register(OrderHistoryCell.self, forCellReuseIdentifier: OrderHistoryCell.reuseId)
        tv.dataSource = self
        tv.delegate   = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .systemBackground
        tv.separatorStyle  = .none
        return tv
    }()
    
    private lazy var loadingView: UIView = {
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        
        overlay.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])
        return overlay
    }()
    
    // MARK: – Init
    
    init(interactor: ProfileBusinessLogic, router: ProfileRoutingLogic) {
        self.interactor = interactor
        self.router     = router
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: – Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showLoading()
        interactor.loadProfile(request: .init())
    }
    
    // MARK: – UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Профиль"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Выйти",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: – Loading overlay helpers
    
    private func showLoading()  { loadingView.isHidden = false }
    private func hideLoading()  { loadingView.isHidden = true  }
    
    // MARK: – Actions
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Выйти из аккаунта?",
            message: "Вы уверены?",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "Отмена", style: .cancel))
        alert.addAction(.init(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.interactor.logout(request: .init())
        })
        present(alert, animated: true)
    }
}

// MARK: – ProfileDisplayLogic

extension ProfileViewController: ProfileDisplayLogic {
    
    func displayProfile(viewModel: Profile.LoadProfile.ViewModel) {
        userName  = viewModel.name
        userEmail = viewModel.email
        orders    = viewModel.orders
        tableView.reloadData()
        hideLoading()
    }
    
    func displayLogout(viewModel: Profile.Logout.ViewModel) {
        hideLoading()
        router.routeToAuth()
    }
}

// MARK: – UITableViewDataSource / Delegate

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : orders.count
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Профиль" : "История заказов"
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProfileInfoCell", for: indexPath)
            
            var cfg = cell.defaultContentConfiguration()
            cfg.text                    = userName
            cfg.textProperties.font     = .systemFont(ofSize: 18, weight: .semibold)
            cfg.secondaryText           = userEmail
            cfg.secondaryTextProperties.font  = .systemFont(ofSize: 14)
            cfg.secondaryTextProperties.color = .darkGray
            
            cell.contentConfiguration = cfg
            cell.selectionStyle = .none
            return cell
        }
        
        let vm = orders[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: OrderHistoryCell.reuseId,
            for: indexPath) as? OrderHistoryCell else {
            
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        
        let info = "\(vm.totalText) · \(vm.restaurantName)"
        cell.configure(date: vm.dateText, info: info, imageURLs: vm.itemImageURLs)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
