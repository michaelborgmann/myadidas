//
//  HealthKitAssistant.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 15.10.20.
//

import HealthKit

class HealthKitSetupAssistant {
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        guard
            let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let stepsCount = HKQuantityType.quantityType(forIdentifier: .stepCount),
            let distanceType = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)
        
        else {
            completion(false, HealthkitSetupError.dataTypeNotAvailable)
            return
        }
        
        let healthKitTypesToWrite: Set<HKSampleType> = [
            bodyMassIndex,
            activeEnergy,
            stepsCount,
            HKObjectType.workoutType()
        ]
        
        let healthKitTypesToRead: Set<HKObjectType> = [
            dateOfBirth,
            bloodType,
            biologicalSex,
            bodyMassIndex,
            height,
            bodyMass,
            stepsCount,
            //distanceType,
            HKObjectType.workoutType()
        ]
        
        HKHealthStore().requestAuthorization(
            toShare: healthKitTypesToWrite,
            read: healthKitTypesToRead
        ) { (success, error) in
          completion(success, error)
        }

    }
    
}
