//
//  ViewController.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30/09/2020.
//

import UIKit

protocol GoalsViewDelegate: class {
    func showError(_ goalsViewController: GoalsViewController, emoji: String, title: String, details: String)
    func showProfile(_ goalsViewController: GoalsViewController)
}

class GoalsViewController: UIViewController, ViewModelBindalbe {
    
    // MARK: Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Properties
    
    private let viewModel: GoalsViewModel?
    
    private weak var delegate: GoalsViewDelegate?
    
    // MARK: - Lifecycle
    
    required public init?<T>(coder: NSCoder, viewModel: T) {
        self.viewModel = viewModel as? GoalsViewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func showProfile() {
        delegate?.showProfile(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "GoalCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "GoalCell")
        
        setupNavigationController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if NetworkMonitor.shared.isConnected {
            fetchAllGoals()
        } else if viewModel?.goals != nil {
            collectionView.reloadData()
            
            NetworkMonitor.shared.delegate = self
            
        } else {
            delegate?.showError(
                self,
                emoji: "😱",
                title: "Ooops",
                details: "Please connect to the internet and try again."
            )
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopActivityIndicator()
    }
    
    // MARK: - Actions
    
}

// MARK: - Setup View Controller

extension GoalsViewController {
    
    private func setupNavigationController() {
        
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "texgyreadventor-bold", size: 32)!
        ]
        
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        title = "Goals"
        
        //
                
        let defaultProfileImage = UIImage(systemName: "person.circle.fill")
        
        let button = UIBarButtonItem(
            image: defaultProfileImage,
            style: .plain,
            target: self,
            action: #selector(showProfile)
        )
        
        button.tintColor = .black
        
        navigationItem.rightBarButtonItem = button
    }

}

// MARK: - Network Monitor

extension GoalsViewController: NetworkMonitorDelegate {
    
    func onConnect() {
        DispatchQueue.main.async {
            self.fetchAllGoals()
        }
    }
    
    func onDisconnect() {
        // nothing to do
    }
    
}

// MARK: - Networking

extension GoalsViewController {
    
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

extension GoalsViewController: UICollectionViewDataSource {
    
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

extension GoalsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width - 100, height: 400)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 75
    }
        
}

// MARK: - Storyboard

extension GoalsViewController: StoryboardInstantiable {
    
    class func instantiate(with viewModel: GoalsViewModel, delegate: GoalsViewDelegate) -> GoalsViewController {
        let viewController = instanceFromStoryboard(with: viewModel)
        viewController.delegate = delegate
        return viewController
    }
    
}


