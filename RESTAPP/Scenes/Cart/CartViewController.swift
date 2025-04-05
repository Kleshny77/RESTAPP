// CartViewController.swift

import UIKit

protocol CartDisplayLogic: AnyObject {
    func displayCart(viewModel: Cart.Load.ViewModel)
}

final class CartViewController: UIViewController, CartDisplayLogic {
    var interactor: CartBusinessLogic?
    var router: (NSObjectProtocol & CartRoutingLogic)?
    private var items: [CartItemViewModel] = []

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle      = .none
        tv.rowHeight           = UITableView.automaticDimension
        tv.estimatedRowHeight  = 80
        tv.allowsSelection     = true
        tv.showsVerticalScrollIndicator = false
        tv.register(CartMealCell.self, forCellReuseIdentifier: CartMealCell.reuseId)
        return tv
    }()

    private let totalLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        return lbl
    }()
    private let payButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Купить", for: .normal)
        btn.titleLabel?.font      = .systemFont(ofSize: 20, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor       = .systemGreen
        btn.layer.cornerRadius    = 8
        return btn
    }()

    private let footerView: UIView = {
        let v = UIView()
        v.backgroundColor     = .systemBackground
        v.layer.cornerRadius  = 25
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor   = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius  = 14
        v.layer.shadowOffset  = .init(width: 0, height: -4)
        v.layer.masksToBounds = false
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        tableView.dataSource = self
        tableView.delegate   = self
        tableView.delaysContentTouches = false
        (tableView.subviews.compactMap { $0 as? UIScrollView })
            .forEach { $0.delaysContentTouches = false }

        [tableView, footerView].forEach(view.addSubview)
        footerView.addSubview(totalLabel)
        footerView.addSubview(payButton)

        configureHeader()
        configureTableView()
        configureFooter()

        interactor?.loadCart(request: .init())
    }

    func displayCart(viewModel: Cart.Load.ViewModel) {
        items = viewModel.items
        totalLabel.text = viewModel.totalText
        tableView.reloadData()
    }

    private func configureHeader() {
        let header = UIView(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 70))
        let canteen = UILabel(); canteen.text = "Столовая №1"; canteen.font = .systemFont(ofSize: 14, weight: .medium)
        let titleLbl = UILabel(); titleLbl.text = "Корзина"; titleLbl.font = .boldSystemFont(ofSize: 22); titleLbl.textAlignment = .center
        header.addSubview(canteen); header.addSubview(titleLbl)
        titleLbl.pinCenterX(to: header.centerXAnchor); titleLbl.pinTop(to: header.topAnchor, 15)
        canteen.pinCenterX(to: titleLbl.centerXAnchor); canteen.pinTop(to: titleLbl.bottomAnchor, 4)
        tableView.tableHeaderView = header
    }

    private func configureTableView() {
        tableView.pinTop(to: view.safeAreaLayoutGuide)
        tableView.pinLeft(to: view, 16)
        tableView.pinRight(to: view, 16)
        tableView.pinBottom(to: footerView.topAnchor)
    }

    private func configureFooter() {
        footerView.pinLeft(to: view)
        footerView.pinRight(to: view)
        footerView.pinBottom(to: view.safeAreaLayoutGuide)
        totalLabel.pinTop(to: footerView, 12); totalLabel.pinCenterX(to: footerView)
        payButton.pinTop(to: totalLabel.bottomAnchor, 12); payButton.pinHorizontal(to: footerView, 16)
        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        payButton.setHeight(mode: .equal, 44); payButton.pinBottom(to: footerView, 12)
    }
    
    @objc private func payTapped() {
            let total = Int(CartService.shared.totalPrice)
            router?.routeToPayment(total: total)
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
            let count = CartService.shared.getAllItems().first { $0.meal == live.meal }!.count
            cell.update(count: count, priceText: "\(live.meal.price * count) ₽")
            self.totalLabel.text = "Итого: \(CartService.shared.totalPrice) ₽"
            self.tableView.beginUpdates(); self.tableView.endUpdates()
        }

        cell.onDecrease = { [weak self, weak cell] in
            guard let self = self, let cell = cell,
                  let path = self.tableView.indexPath(for: cell) else { return }
            let live = self.items[path.section]
            CartService.shared.remove(meal: live.meal)
            let newCount = CartService.shared.getAllItems().first { $0.meal == live.meal }?.count ?? 0
            if newCount > 0 {
                cell.update(count: newCount, priceText: "\(live.meal.price * newCount) ₽")
                self.tableView.beginUpdates(); self.tableView.endUpdates()
            } else {
                self.items.remove(at: path.section)
                self.tableView.performBatchUpdates({
                    self.tableView.deleteSections(.init(integer: path.section), with: .automatic)
                })
            }
            self.totalLabel.text = "Итого: \(Int(CartService.shared.totalPrice)) ₽"
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
