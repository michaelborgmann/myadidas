//
//  HomeCoordinator.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30.09.20.
//

class HomeCoordinator: Coordinator {
    
    var children: [Coordinator] = []
    var router: Router
    
    public init(router: Router) {
        self.router = router
    }
    
    func present(animated: Bool, onDismissed: (() -> Void)?) {
        let viewModel = MainViewModel()
        viewModel.goals = Goal.persisted().first
        
        let viewController = MainViewController.instantiate(with: viewModel, delegate: self)
        
        router.present(viewController, animated: true)
    }
    
}

// MARK: - Delegates

extension HomeCoordinator: MainViewDelegate {
    
    func showError(emoji: String, title: String, details: String) {
        let viewModel = ErrorViewModel()
        
        viewModel.emoji = emoji
        viewModel.title = title
        viewModel.details = details
        
        let viewController = ErrorViewController.instantiate(with: viewModel, delegate: self)
        router.present(viewController, animated: true)
    }
    
}

extension HomeCoordinator: ErrorViewDelegate {
    
    func dismiss() {
        router.dismiss(animated: true)
    }
    
}
