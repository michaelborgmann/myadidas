//
//  ViewModel.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30.09.20.
//

import Foundation
import RealmSwift

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
        GoalsDataStore.getSteps() { result in
            DispatchQueue.main.async {
                let stepCount = Int(result)
                self.stepsToday = stepCount
                completion()
            }
        }
    }
    
    var stepsToday: Int = 0
    
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
                totalPoints += 0
                
            case .running:
                totalPoints += 0
            }
            
        }
        
        return totalPoints
    }
    
}
