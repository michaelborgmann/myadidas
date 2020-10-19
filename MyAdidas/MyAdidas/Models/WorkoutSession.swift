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
    private (set) var distance: Double!
  
    var intervals: [WorkoutInterval] = []
    var state: WorkoutSessionState = .notStarted
    
    func start() {
        startDate = Date()
        state = .active
    }
    
    func end(with distance: Double) {
        endDate = Date()
        self.distance = distance
        addNewInterval()
        state = .finished
        self.distance = distance
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
            end: endDate,
            distance: distance
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
