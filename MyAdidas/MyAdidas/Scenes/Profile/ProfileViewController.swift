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
    @IBOutlet private var bloodTypeLabel:UILabel!
    @IBOutlet private var biologicalSexLabel:UILabel!
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
    
    private let userHealthProfile = UserHealthProfile()
    
    private func updateHealthInfo() {
        loadAndDisplayAgeSexAndBloodType()
        loadAndDisplayMostRecentWeight()
        loadAndDisplayMostRecentHeight()
    }
    
    private func loadAndDisplayAgeSexAndBloodType() {
        
        do {
            let userAgeSexAndBloodType = try ProfileDataStore.getAgeSexAndBloodType()
            userHealthProfile.age = userAgeSexAndBloodType.age
            userHealthProfile.biologicalSex = userAgeSexAndBloodType.biologicalSex
            userHealthProfile.bloodType = userAgeSexAndBloodType.bloodType
            updateLabels()
        } catch let error {
            self.displayAlert(for: error)
        }

    }
    
    private func updateLabels() {
        if let age = userHealthProfile.age {
            ageLabel.text = "\(age)"
        }

        if let biologicalSex = userHealthProfile.biologicalSex {
            biologicalSexLabel.text = biologicalSex.stringRepresentation
        }

        if let bloodType = userHealthProfile.bloodType {
            bloodTypeLabel.text = bloodType.stringRepresentation
        }

    }
  
    private func loadAndDisplayMostRecentHeight() {
        
    }
    
    private func loadAndDisplayMostRecentWeight() {
        
    }
    
    private func saveBodyMassIndexToHealthKit() {
        
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
