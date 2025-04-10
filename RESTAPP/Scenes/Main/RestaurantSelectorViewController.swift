//
//  RestaurantSelectorViewController.swift
//  RESTAPP
//
//  Created by Артём on 04.04.2025.
//

import UIKit
import Foundation

protocol RestaurantSelectorDelegate: AnyObject {
    func restaurantSelectorDidSelect(_ restaurant: Restaurant)
}

class RestaurantSelectorViewController: UIViewController {
    weak var delegate: RestaurantSelectorDelegate?
    private var restaurants: [Restaurant] = []
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "RestaurantCell")
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Выберите ресторан"
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func configure(with restaurants: [Restaurant]) {
        self.restaurants = restaurants
        tableView.reloadData()
    }
}

extension RestaurantSelectorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath)
        let restaurant = restaurants[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = restaurant.name
        content.secondaryText = restaurant.openingHours.currentDaySchedule
        cell.contentConfiguration = content
        
        return cell
    }
}

extension RestaurantSelectorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedRestaurant = restaurants[indexPath.row]
        delegate?.restaurantSelectorDidSelect(selectedRestaurant)
        dismiss(animated: true)
    }
} 
