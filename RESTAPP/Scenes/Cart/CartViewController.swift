//
//  CartViewController.swift
//  RESTAPP
//
//  Created by Артём on 28.03.2025.
//

import UIKit
import Foundation

protocol CartDisplayLogic: AnyObject {
    func displayCart(viewModel: Cart.Load.ViewModel)
}

final class CartViewController: UIViewController, CartDisplayLogic {
    var interactor: CartBusinessLogic?
    var router: (NSObjectProtocol & CartRoutingLogic)?
    private var items: [CartItemViewModel] = []

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 80
        tv.allowsSelection = true
        tv.showsVerticalScrollIndicator = false
        tv.register(CartMealCell.self, forCellReuseIdentifier: CartMealCell.reuseId)
        return tv
    }()

    private lazy var totalLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        lbl.text = "Итого: 0 ₽"
        return lbl
    }()

    private lazy var payButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Купить", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemGreen
        btn.layer.cornerRadius = 8
        return btn
    }()

    private lazy var footerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 25
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 14
        v.layer.shadowOffset = .init(width: 0, height: -4)
        v.layer.masksToBounds = false
        return v
    }()
    
    private lazy var headerView: UIView = {
        let header = UIView(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 70))
        
        let titleLabel = UILabel()
        titleLabel.text = "Корзина"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        
        let restaurantLabel = UILabel()
        restaurantLabel.text = RestaurantService.shared.currentRestaurant?.name ?? "Ресторан"
        restaurantLabel.font = .systemFont(ofSize: 14, weight: .medium)
        restaurantLabel.textAlignment = .center
        
        header.addSubview(titleLabel)
        header.addSubview(restaurantLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        restaurantLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: header.topAnchor, constant: 15),
            
            restaurantLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            restaurantLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])
        
        return header
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavBar()
        configureTableView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(restaurantDidChange),
            name: .restaurantDidChange,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDidChange),
            name: .cartDidChange,
            object: nil
        )
        
        interactor?.loadCart(request: .init())
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Закрыть",
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
    }
    
    @objc private func restaurantDidChange() {
        if let restaurantLabel = headerView.subviews.last as? UILabel {
            restaurantLabel.text = RestaurantService.shared.currentRestaurant?.name ?? "Ресторан"
        }
    }
    
    @objc private func cartDidChange() {
        interactor?.loadCart(request: .init())
    }

    func displayCart(viewModel: Cart.Load.ViewModel) {
        items = viewModel.items
        totalLabel.text = viewModel.totalText
        tableView.reloadData()
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.delaysContentTouches = false
        (tableView.subviews.compactMap { $0 as? UIScrollView })
            .forEach { $0.delaysContentTouches = false }

        [tableView, footerView].forEach(view.addSubview)
        footerView.addSubview(totalLabel)
        footerView.addSubview(payButton)

        configureTableViewLayout()
        configureHeader()
        configureFooter()
    }

    private func configureTableViewLayout() {
        tableView.pinTop(to: view.safeAreaLayoutGuide)
        tableView.pinLeft(to: view, 16)
        tableView.pinRight(to: view, 16)
        tableView.pinBottom(to: footerView.topAnchor)
    }
    
    private func configureHeader() {
        tableView.tableHeaderView = headerView
    }

    private func configureFooter() {
        footerView.pinLeft(to: view)
        footerView.pinRight(to: view)
        footerView.pinBottom(to: view.safeAreaLayoutGuide)
        totalLabel.pinTop(to: footerView, 12)
        totalLabel.pinCenterX(to: footerView)
        payButton.pinTop(to: totalLabel.bottomAnchor, 12)
        payButton.pinHorizontal(to: footerView, 16)
        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        payButton.setHeight(mode: .equal, 44)
        payButton.pinBottom(to: footerView, 12)
    }
    
    @objc private func payTapped() {
        router?.routeToPayment()
    }

    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension CartViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { items.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CartMealCell.reuseId,
                for: indexPath
        ) as? CartMealCell else {
            return UITableViewCell()
        }

        let vm = items[indexPath.section]
        cell.configure(with: vm)

        cell.onIncrease = { [weak self, weak cell] in
            guard let self = self, let cell = cell,
                  let path = self.tableView.indexPath(for: cell) else { return }
            let live = self.items[path.section]
            CartService.shared.add(meal: live.meal)
        }

        cell.onDecrease = { [weak self, weak cell] in
            guard let self = self, let cell = cell,
                  let path = self.tableView.indexPath(for: cell) else { return }
            let live = self.items[path.section]
            CartService.shared.remove(meal: live.meal)
        }

        return cell
    }
}

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let meal = items[indexPath.section].meal
        router?.routeToMealDetail(meal: meal)
    }
}
