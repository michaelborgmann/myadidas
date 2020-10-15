//
//  ViewController.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30/09/2020.
//

import UIKit

protocol MainViewDelegate: class {
    func showError(emoji: String, title: String, details: String)
}

class MainViewController: UIViewController, ViewModelBindalbe {
    
    // MARK: Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        
        let nib = UINib(nibName: "GoalCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "GoalCell")
        
        NetworkMonitor.shared.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if NetworkMonitor.shared.isConnected {
            //fetchAllGoals()
        } else if viewModel?.goals != nil {
            collectionView.reloadData()
        } else {
            delegate?.showError(
                emoji: "😱",
                title: "Ooops",
                details: "Please connect to the internet and try again."
            )
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopActivityIndicator()
        
        NetworkMonitor.shared.stop()
    }

}

// MARK: - Networking

extension MainViewController {
    
    private func fetchAllGoals() {
        startActivityIndicator()
        
        Service.fetchGoals() { goals in
            
            DispatchQueue.main.async {
                self.viewModel?.goals = goals
                self.viewModel?.persist()
                
                self.collectionView.reloadData()
                self.stopActivityIndicator()
            }
            
        }
    }
    
}

// MARK: - Collection View

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.goals?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GoalCell", for: indexPath) as? GoalCollectionViewCell,
            let goal = viewModel?.goals?.items[indexPath.row]
        else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: goal)
        
        return cell
    }
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width - 100, height: 400)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 75
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


