//
//  WorkoutDataStore.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 18.10.20.
//

import HealthKit

class WorkoutDataStore {
    
    class func save(activityType: HKWorkoutActivityType, workout: Workout, completion: @escaping ((Bool, Error?) -> Swift.Void)) {
    
        let healthStore = HKHealthStore()
        
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = activityType

        let builder = HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: workoutConfiguration,
            device: .local()
        )
            
        builder.beginCollection(withStart: workout.start) { (success, error) in
            
            guard success else {
                completion(false, error)
                return
            }
            
            guard
                let distanceWalkingRunning = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
            else {
                completion(false, nil)
                return
            }
            
            let distanceSample = HKCumulativeQuantitySample(
                type: distanceWalkingRunning,
                quantity: HKQuantity(unit: .meter(), doubleValue: workout.distance),
                start: workout.start,
                end: workout.end
            )
            
            builder.add([distanceSample]) { (success, error) in
                guard success else {
                    completion(false, error)
                    return
                }
                  
                
                builder.endCollection(withEnd: workout.end) { (success, error) in
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
    
    class func loadWorkouts(activityType: HKWorkoutActivityType, completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        
        let workoutPredicate = HKQuery.predicateForWorkouts(with: activityType)
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
