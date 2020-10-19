//
//  WorkoutViewController.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 18.10.20.
//

import UIKit
import CoreLocation
import HealthKit

protocol WorkoutViewDelegate: class {
    func dismiss()
    func save()
    func stop()
}

class WorkoutViewController: UIViewController, ViewModelBindalbe {
    
    // MARK: - Outlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
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
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10.0
        locationManager.allowsBackgroundLocationUpdates = true
        
        locationManager.requestAlwaysAuthorization()
        
        return locationManager
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
        
        updateUI()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(finishWorkout))
        view.addGestureRecognizer(tap)
        
        beginWorkout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideStatusAndNavBar = true
    }
    
    private func setupLocationManager() {
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
    
    private func updateUI() {
        updateTimeLabel()
        updateDistanceLabel()
        updatePaceLabel()
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
    
    private func updateDistanceLabel() {
        distanceLabel.textColor = Style.labelColor
        
        guard let distance = viewModel?.distance else {
            distanceLabel.isHidden = true
            return
        }
        
        distanceLabel.isHidden = false
        
        distanceLabel.text = "Distance: \(distance) km"
    }
    
    private func updatePaceLabel() {
        paceLabel.isHidden = true
    }
    
}

// MARK: - Actions

extension WorkoutViewController {
    
    func beginWorkout() {
        
        viewModel?.locations.removeAll()
        
        viewModel?.session.start()
        
        viewModel?.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.updateUI()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    @objc func finishWorkout() {
        viewModel?.session.end()
        updateTimeLabel()
        
        locationManager.stopUpdatingLocation()
        
        guard let currentWorkout = viewModel?.session.completeWorkout else {
          fatalError("Shouldn't be able to finish workout without saving.")
        }
        
        WorkoutDataStore.save(workout: currentWorkout) { (success, error) in
        
            if success {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.showSavingFailureAlert()
            }
        }
    }
    
    private func showSavingFailureAlert() {
        
        let alert = UIAlertController(
            title: nil,
            message: "There was a problem saving your workout",
            preferredStyle: .alert
        )
        
        let okayAction = UIAlertAction(
            title: "O.K.",
            style: .default,
            handler: nil
        )
        
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Location Tracking

extension WorkoutViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locations = viewModel?.locations else {
            debugPrint("Missing locations")
            return
        }
        
        for location in locations {
            
            if location.horizontalAccuracy < 10 {
                
                if viewModel!.locations.count > 0 {
                    
                    viewModel?.distance += location.distance(from: viewModel!.locations.last!)
                    
                    var coordinates = [CLLocationCoordinate2D]()
                    coordinates.append(viewModel!.locations.last!.coordinate)
                    coordinates.append(location.coordinate)
                    
                    viewModel?.pace = location.distance(from: viewModel!.locations.last!) / location.timestamp.timeIntervalSince(viewModel!.locations.last!.timestamp)
                    
                }
                
            }
            
            viewModel?.locations.append(location)   
        }
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
