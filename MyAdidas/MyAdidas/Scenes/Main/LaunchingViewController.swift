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
        
        delegate?.showGoals()
    }
    
}
