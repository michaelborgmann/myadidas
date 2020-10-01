//
//  ViewController.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30/09/2020.
//

import UIKit

protocol MainViewDelegate: class {
    func doSomething()
}

class MainViewController: UIViewController, ViewModelBindalbe {
    
    // MARK: Properties
    
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
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Service.fetchGoals() { result in
            print(result)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopActivityIndicator()
    }

}

// MARK: - Networking

extension MainViewController {
    
    private func fetchAllLessons() {
        startActivityIndicator()
        
        Service.fetchGoals() { goals in
            self.viewModel?.goals = goals
            
            DispatchQueue.main.async {
                // ... do something
                self.stopActivityIndicator()
            }
        }
    }
    
}

// MARK: - Collection View

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    
}

// MARK: - Storyboard

extension MainViewController: StoryboardInstantiable {
    
    class func instantiate(with viewModel: MainViewModel, delegate: MainViewDelegate) -> MainViewController {
        let viewController = instanceFromStoryboard(with: viewModel)
        viewController.delegate = delegate
        return viewController
    }
    
}


