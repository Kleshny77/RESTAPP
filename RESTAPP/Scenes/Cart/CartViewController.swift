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

    // MARK: - VIP
    var interactor: CartBusinessLogic?
    var router    : (NSObjectProtocol & CartRoutingLogic)?

    // MARK: - State
    private var items: [CartItemViewModel] = []

    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle              = .none
        tv.rowHeight                   = UITableView.automaticDimension
        tv.estimatedRowHeight          = 80
        tv.allowsSelection             = true
        tv.showsVerticalScrollIndicator = false
        tv.register(CartMealCell.self, forCellReuseIdentifier: CartMealCell.reuseId)
        return tv
    }()

    private lazy var totalLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.text = "Итого: 0 ₽"
        return l
    }()

    private lazy var payButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Купить", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .systemGreen
        b.layer.cornerRadius = 8
        b.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        return b
    }()

    private lazy var footerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius  = 25
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor   = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius  = 14
        v.layer.shadowOffset  = .init(width: 0, height: -4)
        v.layer.masksToBounds = false
        return v
    }()

    private lazy var headerView: UIView = {
        let header = UIView(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 70))

        let title = UILabel()
        title.text = "Корзина"
        title.font = .boldSystemFont(ofSize: 22)
        title.textAlignment = .center

        let restaurant = UILabel()
        restaurant.text = RestaurantService.shared.currentRestaurant?.name ?? "Ресторан"
        restaurant.font = .systemFont(ofSize: 14, weight: .medium)
        restaurant.textAlignment = .center

        [title, restaurant].forEach { $0.translatesAutoresizingMaskIntoConstraints = false
                                     header.addSubview($0) }

        NSLayoutConstraint.activate([
            title.centerXAnchor   .constraint(equalTo: header.centerXAnchor),
            title.topAnchor       .constraint(equalTo: header.topAnchor, constant: 15),

            restaurant.centerXAnchor.constraint(equalTo: title.centerXAnchor),
            restaurant.topAnchor  .constraint(equalTo: title.bottomAnchor, constant: 4)
        ])
        return header
    }()

    // MARK: - Life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavBar()
        configureTableView()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(restaurantDidChange),
                                               name: .restaurantDidChange,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(cartDidChange),
                                               name: .cartDidChange,
                                               object: nil)

        interactor?.loadCart(request: .init())
        refreshPayButton()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Private helpers
    private func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закрыть",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(closeTapped))
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate   = self

        [tableView, footerView].forEach(view.addSubview)
        footerView.addSubview(totalLabel)
        footerView.addSubview(payButton)

        tableView.pinTop(to: view.safeAreaLayoutGuide)
        tableView.pinLeft(to: view, 16)
        tableView.pinRight(to: view, 16)
        tableView.pinBottom(to: footerView.topAnchor)

        footerView.pinLeft(to: view)
        footerView.pinRight(to: view)
        footerView.pinBottom(to: view.safeAreaLayoutGuide)

        totalLabel.pinTop(to: footerView, 12)
        totalLabel.pinCenterX(to: footerView)

        payButton.pinTop(to: totalLabel.bottomAnchor, 12)
        payButton.pinHorizontal(to: footerView, 16)
        payButton.setHeight(mode: .equal, 44)
        payButton.pinBottom(to: footerView, 12)

        tableView.tableHeaderView = headerView
    }

    private func refreshPayButton() {
        let empty = items.isEmpty
        payButton.isEnabled = !empty
        payButton.alpha     = empty ? 0.4 : 1.0
    }

    // MARK: - Notifications
    @objc private func restaurantDidChange() {
        if let lbl = headerView.subviews.last as? UILabel {
            lbl.text = RestaurantService.shared.currentRestaurant?.name ?? "Ресторан"
        }
    }

    @objc private func cartDidChange(_ n: Notification) {
        guard
            let id    = n.userInfo?["mealId"]   as? String,
            let count = n.userInfo?["newCount"] as? Int,
            let total = n.userInfo?["total"]    as? Int,
            let index = items.firstIndex(where: { $0.id == id })
        else { return }

        if count == 0 {
            items.remove(at: index)
            tableView.deleteSections([index], with: .fade)
        } else {
            items[index].count = count
            items[index].priceText = "\(items[index].meal.price * count) ₽"

            let path = IndexPath(row: 0, section: index)
            if let cell = tableView.cellForRow(at: path) as? CartMealCell {
                cell.update(count: count, priceText: items[index].priceText)
            }
        }
        totalLabel.text = "Итого: \(total) ₽"
        refreshPayButton()
    }

    // MARK: - DisplayLogic
    func displayCart(viewModel: Cart.Load.ViewModel) {
        items = viewModel.items
        totalLabel.text = viewModel.totalText
        tableView.reloadData()
        refreshPayButton()
    }

    // MARK: - Actions
    @objc private func payTapped() { router?.routeToPayment() }
    @objc private func closeTapped() { dismiss(animated: true) }
}

// MARK: - UITableViewDataSource / Delegate
extension CartViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { items.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CartMealCell.reuseId,
                for: indexPath) as? CartMealCell else { return UITableViewCell() }

        let vm = items[indexPath.section]
        cell.configure(with: vm)

        cell.onIncrease = { CartService.shared.add(meal: vm.meal) }
        cell.onDecrease = { CartService.shared.remove(meal: vm.meal) }
        cell.onTap      = { [weak self] in self?.router?.routeToMealDetail(meal: vm.meal) }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
