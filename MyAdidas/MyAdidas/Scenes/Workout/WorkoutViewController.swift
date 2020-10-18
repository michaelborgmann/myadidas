//
//  WorkoutViewController.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 18.10.20.
//

import UIKit

protocol WorkoutViewDelegate: class {
    func dismiss()
    func save()
    func stop()
}

class WorkoutViewController: UIViewController, ViewModelBindalbe {
    
    // MARK: - Properties
    
    private let viewModel: WorkoutViewModel?
    
    private weak var delegate: WorkoutViewDelegate?
    
    private let gradient = CAGradientLayer()
    
    private var hideStatusAndNavBar: Bool = true {
        didSet {
            navigationController?.navigationBar.isHidden = false
//            viewModel?.isStatusBarHidden = hideStatusAndNavBar
        }
    }
    
    // MARK: - Lifecycle
    
    required public init?<T>(coder: NSCoder, viewModel: T) {
        self.viewModel = viewModel as? WorkoutViewModel
        super.init(coder: coder)
    }
    
    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideStatusAndNavBar = false
        
        setupGradient()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideStatusAndNavBar = true
    }
    
    private func setupGradient(colors: Gradient = .error) {

        gradient.frame = view.frame
        
        let colors = Gradient.colors(for: viewModel?.item)
        
        gradient.colors = [
            colors.light.cgColor,
            colors.dark.cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        view.layer.insertSublayer(gradient, at: 0)

    }
    
}

// MARK: - Storyboard

extension WorkoutViewController: StoryboardInstantiable {
    
    class func instantiate(with viewModel: WorkoutViewModel, delegate: WorkoutViewDelegate) -> WorkoutViewController {
        let viewController = instanceFromStoryboard(with: viewModel)
        viewController.delegate = delegate
        return viewController
    }
    
}
