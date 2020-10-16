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

class SplashViewController: UIViewController, ViewModelBindalbe {
    
    // MARK: - Properties
    
    private let viewModel: MainViewModel?
    
    private weak var delegate: MainViewDelegate?
    
    // MARK: - Lifecycle
    
    required public init?<T>(coder: NSCoder, viewModel: T) {
        self.viewModel = viewModel as? MainViewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate?.showGoals()
    }
    
}

// MARK: - Storyboard

extension SplashViewController: StoryboardInstantiable {
    
    class func instantiate(with viewModel: MainViewModel, delegate: MainViewDelegate) -> SplashViewController {
        let viewController = instanceFromStoryboard(with: viewModel)
        viewController.delegate = delegate
        return viewController
    }
    
}
