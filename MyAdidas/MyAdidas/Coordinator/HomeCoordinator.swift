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
        
        Goal.delete()
        
        let viewModel = MainViewModel()
        viewModel.goals = Goal.persisted().first
        
        let viewController = MainViewController.instantiate(with: viewModel, delegate: self)
        
        router.present(viewController, animated: true)
    }
    
}

// MARK: - Delegates

extension HomeCoordinator: MainViewDelegate {
    func doSomething() {
        print("coordinator works")
    }
    
}
