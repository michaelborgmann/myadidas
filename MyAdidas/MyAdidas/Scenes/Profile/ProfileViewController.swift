//
//  ProfileViewController.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 15.10.20.
//

import UIKit
import HealthKit

protocol ProfileViewDelegate: class {
    func doSomething()
}

class ProfileViewController: UITableViewController, ViewModelBindalbe {
    
    // MARK: - Outlets
    
    @IBOutlet private var ageLabel:UILabel!
    @IBOutlet private var biologicalSexLabel:UILabel!
    @IBOutlet private var bloodTypeLabel:UILabel!
    @IBOutlet private var weightLabel:UILabel!
    @IBOutlet private var heightLabel:UILabel!
    @IBOutlet private var bodyMassIndexLabel:UILabel!
    
    // MARK: - Properties
    
    private let viewModel: ProfileViewModel?
    
    private weak var delegate: ProfileViewDelegate?
    
    // MARK: - Lifecycle
    
    required public init?<T>(coder: NSCoder, viewModel: T) {
        self.viewModel = viewModel as? ProfileViewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        
        updateHealthInfo()
    }
        
    private func setupNavigationController() {
        let update = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(saveBodyMassIndexToHealthKit))
        navigationItem.rightBarButtonItem = update
    }
    
}

// MARK: Enums & Constants

extension ProfileViewController {
    
    private enum ProfileSection: Int {
        case ageSexBloodType
        case weightHeightBMI
        case readHealthKitData
        case saveBMI
    }
    
    private enum ProfileDataError: Error {
        
        case missingBodyMassIndex
        
        var localizedDescription: String {
            switch self {
            case .missingBodyMassIndex:
                return "Unable to calculate body mass index with available profile data."
            }
        }
    }
    
}

// MARK: Update UI Components

extension ProfileViewController {
    
    private func updateHealthInfo() {
        loadAndDisplayAgeSexAndBloodType()
        loadAndDisplayMostRecentWeight()
        loadAndDisplayMostRecentHeight()
    }
    
    private func loadAndDisplayAgeSexAndBloodType() {
        
        do {
            let userAgeSexAndBloodType = try ProfileDataStore.getAgeSexAndBloodType()
            viewModel?.userHealthProfile.age = userAgeSexAndBloodType.age
            viewModel?.userHealthProfile.biologicalSex = userAgeSexAndBloodType.biologicalSex
            viewModel?.userHealthProfile.bloodType = userAgeSexAndBloodType.bloodType
            updateLabels()
        } catch let error {
            self.displayAlert(for: error)
        }

    }
    
    private func loadAndDisplayMostRecentWeight() {
        
        guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            print("Body Mass Sample Type is no longer available in HealthKit")
            return
        }
            
        ProfileDataStore.getMostRecentSample(for: weightSampleType) { (sample, error) in
            
            guard let sample = sample else {
                
                if let error = error {
                    self.displayAlert(for: error)
                }
                
                return
            }
              
            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            self.viewModel?.userHealthProfile.weightInKilograms = weightInKilograms
            self.updateLabels()
        }

    }
  
    private func loadAndDisplayMostRecentHeight() {
        
        guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
            print("Height Sample Type is no longer available in HealthKit")
            return
        }
        
        ProfileDataStore.getMostRecentSample(for: heightSampleType) { (sample, error) in
              
            guard let sample = sample else {
              
                if let error = error {
                    self.displayAlert(for: error)
                }
                
                return
            }
            
            let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
            self.viewModel?.userHealthProfile.heightInMeters = heightInMeters
            self.updateLabels()
        }
    }
    
    private func updateLabels() {
        if let age = viewModel?.userHealthProfile.age {
            ageLabel.text = "\(age)"
        }

        if let biologicalSex = viewModel?.userHealthProfile.biologicalSex {
            biologicalSexLabel.text = biologicalSex.stringRepresentation
        }

        if let bloodType = viewModel?.userHealthProfile.bloodType {
            bloodTypeLabel.text = bloodType.stringRepresentation
        }

        if let weight = viewModel?.userHealthProfile.weightInKilograms {
            let weightFormatter = MassFormatter()
            weightFormatter.isForPersonMassUse = true
            weightLabel.text = weightFormatter.string(fromKilograms: weight)
        }
            
        if let height = viewModel?.userHealthProfile.heightInMeters {
            let heightFormatter = LengthFormatter()
            heightFormatter.isForPersonHeightUse = true
            heightLabel.text = heightFormatter.string(fromMeters: height)
        }
           
        if let bodyMassIndex = viewModel?.userHealthProfile.bodyMassIndex {
            bodyMassIndexLabel.text = String(format: "%.02f", bodyMassIndex)
        }

        
    }
    
}

// MARK: - Actions

extension ProfileViewController {
    
    @objc private func saveBodyMassIndexToHealthKit() {
        
        guard let bodyMassIndex = viewModel?.userHealthProfile.bodyMassIndex else {
            displayAlert(for: ProfileDataError.missingBodyMassIndex)
            return
        }
        
        ProfileDataStore.saveBodyMassIndexSample(
            bodyMassIndex: bodyMassIndex,
            date: Date()
        )

    }
    
    private func displayAlert(for error: Error) {
        
        let alert = UIAlertController(
            title: nil,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "O.K.",
                style: .default,
                handler: nil
            )
        )
        
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Table View

extension ProfileViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let section = ProfileSection(rawValue: indexPath.section) else {
            fatalError("A ProfileSection should map to the index path's section")
        }
        
        switch section {
        case .saveBMI:
            saveBodyMassIndexToHealthKit()
        case .readHealthKitData:
            updateHealthInfo()
        default: break
        }
    }
    
}

// MARK: - Storyboard

extension ProfileViewController: StoryboardInstantiable {
    
    class func instantiate(with viewModel: ProfileViewModel, delegate: ProfileViewDelegate) -> ProfileViewController {
        let viewController = instanceFromStoryboard(with: viewModel)
        viewController.delegate = delegate
        return viewController
    }
    
}
