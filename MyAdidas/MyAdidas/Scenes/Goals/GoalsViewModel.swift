//
//  ViewModel.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30.09.20.
//

import Foundation
import RealmSwift
import HealthKit

class GoalsViewModel {
    
    var goals: Goal?
    
    func persist() {
        guard let goals = goals else {
            return
        }
        
        do {
            let realm = try Realm()
            
            debugPrint(try Realm().configuration.fileURL!.absoluteString)
            
            Goal.delete()
                
            try realm.write {
                realm.add(goals)
            }
            
        } catch {
            fatalError("Cannot persist goals")
        }
    }
    
    var isStatusBarHidden = false
    
    var expandedCell: GoalCollectionViewCell?
    var hiddenCells: [GoalCollectionViewCell] = []
    
    func updateSteps(completion: @escaping () -> Void) {
        
        WorkoutDataStore.loadWalkingWorkouts() { (workouts, error) in
            DispatchQueue.main.async {

                if error != nil {
                    debugPrint(error!)
                    return
                }
                
                guard let workouts = workouts else {
                    debugPrint("No workouts found")
                    return
                }
                
                let totalDistance = workouts.reduce(0.0) { (result, workout) in
                    guard let distance = workout.totalDistance else {
                        return result
                    }
                    
                    return result + distance.doubleValue(for: .meter())
                }
                
                
                self.kmToday = Int(totalDistance)
                
                completion()
            }
        }
        
        /*
        GoalsDataStore.getDistance() { result in
            DispatchQueue.main.async {
                
                self.kmToday = Int(result)
                completion()
            }
        }
        */
        
        GoalsDataStore.getSteps() { result in
            DispatchQueue.main.async {
                self.stepsToday = Int(result)
                completion()
            }
        }
    }
    
    var stepsToday: Int = 0
    var kmToday: Int = 0
    
    private var workouts: [HKWorkout]?
    
    var pointsToday: Int? {
        
        guard
            let goals = goals?.items
        else {
            return nil
        }
        
        var totalPoints = 0
        
        goals.forEach { goal in
            
            guard let points = goal.reward?.points else {
                return
            }
            
            switch goal.type {
            
            case .step:
                if stepsToday >= goal.goal {
                    totalPoints += points
                }
                
            case .walking:
                if kmToday >= goal.goal {
                    totalPoints += points
                }
                
            case .running:
                if kmToday >= goal.goal {
                    totalPoints += points
                }
            }
            
        }
        
        return totalPoints
    }
    
}
