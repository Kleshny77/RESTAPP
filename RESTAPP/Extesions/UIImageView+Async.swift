//
//  UIImageView+Async.swift
//  RESTAPP
//
//  Created by Артём on 10.04.2025.
//

import UIKit

extension UIImageView {
    private static var imageCache = NSCache<NSString, UIImage>()
    
    func loadImageAsync(from urlString: String, showLoadingIndicator: Bool = true) async {
        if let cachedImage = UIImageView.imageCache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        }
        
        if showLoadingIndicator {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            activityIndicator.startAnimating()
            self.addSubview(activityIndicator)
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "ImageLoading", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
            }
            
            if let image = UIImage(data: data) {
                UIImageView.imageCache.setObject(image, forKey: urlString as NSString)
                
                DispatchQueue.main.async {
                    self.image = image
                    self.subviews.forEach { view in
                        if let activityIndicator = view as? UIActivityIndicatorView {
                            activityIndicator.stopAnimating()
                            activityIndicator.removeFromSuperview()
                        }
                    }
                }
            }
        } catch {
            print("Error loading image: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.subviews.forEach { view in
                    if let activityIndicator = view as? UIActivityIndicatorView {
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    static func clearImageCache() {
        imageCache.removeAllObjects()
    }
}
