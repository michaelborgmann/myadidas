//
//  HomeCoordinator.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30.09.20.
//

import Foundation

class HomeCoordinator: Coordinator {
    
    var children: [Coordinator] = []
    var router: Router
    
    public init(router: Router) {
        self.router = router
    }
    
    func present(animated: Bool, onDismissed: (() -> Void)?) {
        
        NetworkMonitor.shared.start()
        
        let viewModel = GoalsViewModel()
        viewModel.goals = Goal.persisted().first
        
        let viewController = GoalsViewController.instantiate(with: viewModel, delegate: self)
        
        router.present(viewController, animated: true)
    }
    
}

// MARK: - Delegates

extension HomeCoordinator: GoalsViewDelegate {
    func showError(_ goalsViewController: GoalsViewController, emoji: String, title: String, details: String) {
        
        let viewModel = ErrorViewModel()
        
        viewModel.emoji = emoji
        viewModel.title = title
        viewModel.details = details
        
        let viewController = ErrorViewController.instantiate(with: viewModel, delegate: self)
        
        router = ModalRouter(parentViewController: goalsViewController)
        router.present(viewController, animated: true)
        
    }
    
}

extension HomeCoordinator: ErrorViewDelegate {
    
    func dismiss() {
        DispatchQueue.main.async {
            self.router.dismiss(animated: true)
        }
    }
    
}
