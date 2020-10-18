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
    
    // MARK: - Outlets
    
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Properties
    
    private let viewModel: WorkoutViewModel?
    
    private weak var delegate: WorkoutViewDelegate?
    
    private let gradient = CAGradientLayer()
    
    private var hideStatusAndNavBar: Bool = true {
        didSet {
            navigationController?.navigationBar.isHidden = true
        }
    }
    
    private lazy var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    required public init?<T>(coder: NSCoder, viewModel: T) {
        self.viewModel = viewModel as? WorkoutViewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideStatusAndNavBar = false
        
        setupGradient()
        
        updateTimeLabel()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(finishWorkout))
        view.addGestureRecognizer(tap)
        
        beginWorkout()
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
    
    private func setupUI() {
        updateTimeLabel()
    }
    
    private func updateTimeLabel() {

        timeLabel.textColor = Style.labelColor

        guard let startDate = viewModel?.session.startDate else {
            timeLabel.text = "00:00:00"
            return
        }
        
        let duration = Date().timeIntervalSince(startDate)
        timeLabel.text = durationFormatter.string(from: duration)
    }
    
}

// MARK: - Actions

extension WorkoutViewController {
    
    func beginWorkout() {
        viewModel?.session.start()
        
        viewModel?.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.updateTimeLabel()
        }
    }
    
    @objc func finishWorkout() {
        viewModel?.session.end()
        updateTimeLabel()
        
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Constants

extension WorkoutViewController {
    
    private struct Style {
        static let labelColor = UIColor.white
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
