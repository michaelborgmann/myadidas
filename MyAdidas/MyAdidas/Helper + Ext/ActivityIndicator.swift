//
//  ActivityIndicator.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30.09.20.
//

import UIKit

extension UIViewController {
    
    private static let activityIndicatorTag = UUID().hashValue
    
    func startActivityIndicator() {
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        
        activityIndicator.frame = view.frame
        activityIndicator.center = view.center
        
        activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        activityIndicator.layer.cornerRadius = 10
        activityIndicator.color = .black
        
        activityIndicator.tag = UIViewController.activityIndicatorTag
        
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
        
            if let activityIndicator = self.view.subviews.first(where: { $0.tag == UIViewController.activityIndicatorTag }) as? UIActivityIndicatorView {
            
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                
            }
        }
    }
    
}
