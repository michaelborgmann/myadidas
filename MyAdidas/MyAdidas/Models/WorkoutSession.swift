//
//  WorkoutSession.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 18.10.20.
//

import Foundation

class WorkoutSession {
    
    enum WorkoutSessionState {
        case notStarted
        case active
        case finished
    }
    
    private (set) var startDate: Date!
    private (set) var endDate: Date!
  
    var intervals: [WorkoutInterval] = []
    var state: WorkoutSessionState = .notStarted
    
    func start() {
        startDate = Date()
        state = .active
    }
    
    func end() {
        endDate = Date()
        addNewInterval()
        state = .finished
    }
    
    func clear() {
        startDate = nil
        endDate = nil
        state = .notStarted
        intervals.removeAll()
    }
  
    private func addNewInterval() {
        let interval = WorkoutInterval(
            start: startDate,
            end: endDate
        )
        
        intervals.append(interval)
    }
    
    var completeWorkout: Workout? {
        guard state == .finished, intervals.count > 0 else {
            return nil
        }
        
        return Workout(with: intervals)
    }
}
