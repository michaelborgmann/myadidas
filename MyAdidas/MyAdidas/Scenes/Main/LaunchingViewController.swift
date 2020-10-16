//
//  MainViewController.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 16.10.20.
//

import UIKit

protocol MainViewDelegate: class {
    func showGoals()
}

class LaunchingViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: MainViewDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkMonitor.shared.start()
        
        authorizeHealthKit()
        
        delegate?.showGoals()
    }
    
    private func authorizeHealthKit() {
        
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
            
                return
            }
          
            print("HealthKit Successfully Authorized.")
        }
    }
    
}
