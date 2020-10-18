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
    func startWorkout(_ goalsViewController: GoalsViewController, _ item: Item)
}

class GoalsViewController: UIViewController, ViewModelBindalbe {
    
    // MARK: Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Properties
    
    private let viewModel: GoalsViewModel?
    
    private weak var delegate: GoalsViewDelegate?
    
    override var prefersStatusBarHidden: Bool {
        
        guard let viewModel = viewModel else {
            return false
        }
        
        return viewModel.isStatusBarHidden
    }
    
    private var hideStatusAndNavBar: Bool = true {
        didSet {
            navigationController?.navigationBar.isHidden = hideStatusAndNavBar
            viewModel?.isStatusBarHidden = hideStatusAndNavBar
        }
    }
    
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
        
        viewModel?.updateSteps() {
            self.updatePoints()
        }
        
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
    
    private func updatePoints() {
        guard let pointsToday = viewModel?.pointsToday else {
            return
        }
        
        let points = UIBarButtonItem(title: "\(pointsToday) Points", style: .plain, target: self, action: nil)
        points.tintColor = .black
        
        navigationItem.leftBarButtonItem = points
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
        
        cell.configure(with: goal, progressToday: viewModel?.stepsToday) {
            self.startWorkoutAlert(goal)
        }
        
        return cell
    }
}

extension GoalsViewController: UICollectionViewDelegate {
    
    private func animiateActivityRing() {
        guard let selectedCell = viewModel?.expandedCell else {
            return
        }
        
        UIView.animate(withDuration: 0.5 * selectedCell.progress) {
            selectedCell.activityRingView.progress = selectedCell.progress
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let springParameters = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: .zero)
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: springParameters)
        
        view.isUserInteractionEnabled = false
        
        if let selectedCell = viewModel?.expandedCell {
            
            hideStatusAndNavBar = false
            
            animator.addAnimations {
                selectedCell.collapse()
                
                for cell in self.viewModel!.hiddenCells {
                    cell.show()
                }
            }
            
            animator.addCompletion { _ in
                collectionView.isScrollEnabled = true
                
                self.viewModel?.expandedCell = nil
                self.viewModel?.hiddenCells.removeAll()
            }
            
            selectedCell.activityRingView.progress = 0
        
        } else {
            
            let selectedCell = collectionView.cellForItem(at: indexPath)! as! GoalCollectionViewCell
            let selectedCellFrame = selectedCell.frame
            viewModel?.expandedCell = selectedCell
            
            animiateActivityRing()
            
            hideStatusAndNavBar = true
            collectionView.isScrollEnabled = false
            
            selectedCell.startStop(self)
            
            viewModel?.hiddenCells = collectionView.visibleCells
                .map { $0 as! GoalCollectionViewCell }
                .filter { $0 != selectedCell }
            
            animator.addAnimations {
                selectedCell.expand(in: collectionView)
                
                for cell in self.viewModel!.hiddenCells {
                    cell.hide(in: collectionView, selectedCellFrame: selectedCellFrame)
                }
            }
        }

        animator.addAnimations {
            self.setNeedsStatusBarAppearanceUpdate()
        }

        animator.addCompletion { _ in
            self.view.isUserInteractionEnabled = true
        }
        
        animator.startAnimation()
    }
}

extension GoalsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width - 100, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 75
    }
        
}

// MARK: - Alerts

extension GoalsViewController {
    
    private func startWorkoutAlert(_ item: Item) {
        
        let alert = UIAlertController(
            title: nil,
            message: "Start a Walking session?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(
            title: "Yes",
            style: .default
        ) { (action) in
            self.delegate?.startWorkout(self, item)
        }
        
        let noAction = UIAlertAction(
            title: "No",
            style: .cancel,
            handler: nil
        )
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
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


