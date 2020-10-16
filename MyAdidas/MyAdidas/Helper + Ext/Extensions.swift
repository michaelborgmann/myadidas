//
//  Extensions.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 15.10.20.
//

import HealthKit

extension HKBiologicalSex {
  
    var stringRepresentation: String {
        switch self {
        case .notSet:
            return "Unknown"
        case .female:
            return "Female"
        case .male:
            return "Male"
        case .other:
            return "Other"
        @unknown default:
            return "Unknown"
        }
    }
}

extension HKBloodType {
  
    var stringRepresentation: String {
        switch self {
        case .notSet:
            return "Unknown"
        case .aPositive:
            return "A+"
        case .aNegative:
            return "A-"
        case .bPositive:
            return "B+"
        case .bNegative:
            return "B-"
        case .abPositive:
            return "AB+"
        case .abNegative:
            return "AB-"
        case .oPositive:
            return "O+"
        case .oNegative:
            return "O-"
        @unknown default:
            return "Unknown"
        }
    }
    
}
