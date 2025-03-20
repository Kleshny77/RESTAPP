//
//  UIImageView+Async.swift
//  RESTAPP
//
//  Created by Артём on 10.04.2025.
//

import UIKit

extension UIImageView {
    func loadImageAsync(from urlString: String) async {
        guard let url = URL(string: urlString) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        } catch {
            print("Error loading image: \(error.localizedDescription)")
        }
    }
}
