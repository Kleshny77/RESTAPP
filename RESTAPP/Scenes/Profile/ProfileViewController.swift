//
//  ProfileViewController.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

import UIKit

// MARK: - ProfileDisplayLogic

protocol ProfileDisplayLogic: AnyObject {
    func displayUser(viewModel: Profile.LoadUser.ViewModel)
    func displayOrders(viewModel: Profile.LoadOrders.ViewModel)
    func displayLogout()
}

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController, ProfileDisplayLogic {

    // MARK: Properties

    private let interactor: ProfileBusinessLogic
    private let router: ProfileRoutingLogic
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let ordersTableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "OrderCell")
        return tv
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Выйти из аккаунта", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        return button
    }()
    
    private var orders: [OrderViewModel] = []

    // MARK: - Init

    init(interactor: ProfileBusinessLogic,
         router: ProfileRoutingLogic) {
        self.interactor = interactor
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        ordersTableView.dataSource = self
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        interactor.loadUser(request: .init())
        interactor.loadOrders(request: .init())
    }

    // MARK: - UI

    private func configureUI() {
        view.backgroundColor = .systemBackground
        configureLogoutButton()
        configureNameLabel()
        configureOrdersTableView()
    }

    private func configureLogoutButton() {
        view.addSubview(logoutButton)
        logoutButton.pinLeft(to: view, 20)
        logoutButton.pinRight(to: view, 20)
        logoutButton.pinBottom(to: view.safeAreaLayoutGuide, 20)
        logoutButton.setHeight(mode: .equal, 50)
    }

    private func configureNameLabel() {
        view.addSubview(nameLabel)
        nameLabel.pinTop(to: view.safeAreaLayoutGuide, 20)
        nameLabel.pinLeft(to: view, 20)
        nameLabel.pinRight(to: view, 20)
    }

    private func configureOrdersTableView() {
        view.addSubview(ordersTableView)
        ordersTableView.pinTop(to: nameLabel.bottomAnchor, 20)
        ordersTableView.pinLeft(to: view, 20)
        ordersTableView.pinRight(to: view, 20)
        // Важный момент: logoutButton уже добавлен во view, поэтому constraint корректен:
        ordersTableView.pinBottom(to: logoutButton.topAnchor, 20)
    }

    // MARK: - Display Logic

    func displayUser(viewModel: Profile.LoadUser.ViewModel) {
        nameLabel.text = viewModel.displayName
    }

    func displayOrders(viewModel: Profile.LoadOrders.ViewModel) {
        orders = viewModel.orders
        ordersTableView.reloadData()
    }

    func displayLogout() {
        router.routeToLogin()
    }

    // MARK: - Actions

    @objc private func logoutTapped() {
        interactor.logout(request: .init())
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath)
        let orderVM = orders[indexPath.row]
        cell.textLabel?.text = "Заказ \(orderVM.orderId): \(orderVM.dateText) — \(orderVM.totalText)"
        return cell
    }
}
