//
//  ProfileViewController.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

import UIKit

// MARK: - ProfileDisplayLogic

protocol ProfileDisplayLogic: AnyObject {
    func displayProfile(viewModel: Profile.LoadProfile.ViewModel)
    func displayLogout(viewModel: Profile.Logout.ViewModel)
}

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController {

    // MARK: Properties

    private let interactor: ProfileBusinessLogic
    private let router: ProfileRoutingLogic
    
    private var orders: [OrderCellViewModel] = []
    private var userName: String = ""
    private var userEmail: String = ""
    
    // MARK: - UI

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "OrderCell")
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Lifecycle

    init(interactor: ProfileBusinessLogic, router: ProfileRoutingLogic) {
        self.interactor = interactor
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Обновляем данные при каждом появлении экрана
        loadData()
    }

    // MARK: - Setup

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
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadData() {
        interactor.loadProfile(request: .init())
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Выйти из аккаунта?",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.interactor.logout(request: .init())
        })
        
        present(alert, animated: true)
    }
}

// MARK: - Display Logic

extension ProfileViewController: ProfileDisplayLogic {
    func displayProfile(viewModel: Profile.LoadProfile.ViewModel) {
        userName = viewModel.name
        userEmail = viewModel.email
        orders = viewModel.orders
        title = viewModel.name
        tableView.reloadData()
    }
    
    func displayLogout(viewModel: Profile.Logout.ViewModel) {
        router.routeToAuth()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Информация профиля
        case 1: return orders.count // История заказов
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        switch indexPath.section {
        case 0:
            content.text = userName
            content.textProperties.font = .systemFont(ofSize: 17, weight: .semibold)
            content.secondaryText = userEmail
            content.secondaryTextProperties.font = .systemFont(ofSize: 14)
            content.secondaryTextProperties.color = .systemGray
            cell.selectionStyle = .none
            
        case 1:
            let order = orders[indexPath.row]
            content.text = order.date
            content.secondaryText = "\(order.items)\nИтого: \(order.total)"
            content.secondaryTextProperties.numberOfLines = 0
            cell.accessoryType = .none
            
        default:
            break
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Профиль"
        case 1: return "История заказов"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
