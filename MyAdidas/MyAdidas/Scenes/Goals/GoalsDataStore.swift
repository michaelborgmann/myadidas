//
//  GoalsDataStore.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 16.10.20.
//

import HealthKit

class GoalsDataStore {
    
    class func getSteps(completion: @escaping (Double) -> Void) {
        
        let healthKitStore = HKHealthStore()
        
        let stepsCount = HKQuantityType.quantityType(forIdentifier: .stepCount)
        
        let date = Date()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: date)
        
        let predicate = HKQuery.predicateForSamples(withStart: newDate, end: Date(), options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: newDate as Date, intervalComponents:interval)

        query.initialResultsHandler = { query, results, error in

            if error != nil {
                return
            }

            if let myResults = results {
                myResults.enumerateStatistics(from: newDate, to: Date()) {
                    statistics, stop in

                    if let quantity = statistics.sumQuantity() {

                        let steps = quantity.doubleValue(for: HKUnit.count())
                        
                        completion(steps)

                    }
                }
            }


        }

        healthKitStore.execute(query)
    }
    
}

