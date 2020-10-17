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
    
    override var prefersStatusBarHidden: Bool {
        
        guard let viewModel = viewModel else {
            return false
        }
        
        return viewModel.isStatusBarHidden
    }
    
    private var showStatusAndNavBar: Bool = true {
        didSet {
            navigationController?.navigationBar.isHidden = showStatusAndNavBar
            viewModel?.isStatusBarHidden = showStatusAndNavBar
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
        
        setupNavigationController()
        
        viewModel?.updateSteps()
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
        
        cell.configure(with: goal, goal: viewModel?.stepsToday)
        
        return cell
    }
}

extension GoalsViewController: UICollectionViewDelegate {
    
    private func updateReward(for selectedCell: GoalCollectionViewCell, with indexPath: IndexPath) {
        
        viewModel?.expandedCell
        
        let goal = self.viewModel?.goals?.items[indexPath.row].goal
        let stepsToday = self.viewModel?.stepsToday
        let percent = Double(stepsToday! / goal!)
        
        let item = viewModel?.goals?.items[indexPath.row]
        let colors = Gradient.colors(for: item)
        
        selectedCell.activityRingView.startColor = colors.end
        selectedCell.activityRingView.endColor = colors.start
        
        
        UIView.animate(withDuration: 0.5 * percent) {
            selectedCell.activityRingView.progress = percent
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let springParameters = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: .zero)
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: springParameters)
        
        view.isUserInteractionEnabled = false
        
        if let selectedCell = viewModel?.expandedCell {
            
            showStatusAndNavBar = false
            
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
            
            updateReward(for: selectedCell, with: indexPath)
            
            showStatusAndNavBar = true
            collectionView.isScrollEnabled = false
            
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

// MARK: - Storyboard

extension GoalsViewController: StoryboardInstantiable {
    
    class func instantiate(with viewModel: GoalsViewModel, delegate: GoalsViewDelegate) -> GoalsViewController {
        let viewController = instanceFromStoryboard(with: viewModel)
        viewController.delegate = delegate
        return viewController
    }
    
}


