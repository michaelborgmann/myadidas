//
//  WorkoutDataStore.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 18.10.20.
//

import HealthKit

class WorkoutDataStore {
    
    class func save(
        walkingWorkout: WorkoutInterval,
        completion: @escaping ((Bool, Error?) -> Swift.Void)
    ) {
    
        let healthStore = HKHealthStore()
        
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .walking

        let builder = HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: workoutConfiguration,
            device: .local()
        )
            
        builder.beginCollection(withStart: walkingWorkout.start) { (success, error) in
            
            guard success else {
                completion(false, error)
                return
            }
            
            guard
                let activeEnergyBurned = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
                let walkingSpeed = HKQuantityType.quantityType(forIdentifier: .walkingSpeed),
                let walkingStepLength = HKQuantityType.quantityType(forIdentifier: .walkingStepLength),
                let walkingAsymmetryPercentage = HKQuantityType.quantityType(forIdentifier: .walkingAsymmetryPercentage),
                let walkingHeartRateAverage = HKQuantityType.quantityType(forIdentifier: .walkingHeartRateAverage),
                let walkingDoubleSupportPercentage = HKQuantityType.quantityType(forIdentifier: .walkingDoubleSupportPercentage),
                let distanceWalkingRunning = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
            else {
                completion(false, nil)
                return
            }
                
            let unit = HKUnit.kilocalorie()
            let totalEnergyBurned = walkingWorkout.totalEnergyBurned
            let quantity = HKQuantity(unit: unit, doubleValue: totalEnergyBurned)
            
            let sample = HKCumulativeQuantitySample (
                type: activeEnergyBurned,
                quantity: quantity,
                start: walkingWorkout.start,
                end: walkingWorkout.end
            )
            
            builder.add([sample]) { (success, error) in
                guard success else {
                    completion(false, error)
                    return
                }
                  
                
                builder.endCollection(withEnd: walkingWorkout.end) { (success, error) in
                    guard success else {
                        completion(false, error)
                        return
                    }
                    
                    
                    builder.finishWorkout { (_, error) in
                        let success = error == nil
                        completion(success, error)
                    }
                }
            }
        }
    }
    
    class func loadWalkingWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .walking)
        let sourcePredicate = HKQuery.predicateForObjects(from: .default())
        
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate, sourcePredicate])
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: compound,
            limit: 0,
            sortDescriptors: [sortDescriptor]
        ) { (query, samples, error) in
            
            DispatchQueue.main.async {
                guard
                    let samples = samples as? [HKWorkout],
                    error == nil
                else {
                    completion(nil, error)
                    return
                }
              
                completion(samples, nil)
            }
        }
        
        HKHealthStore().execute(query)

    }
    
}
