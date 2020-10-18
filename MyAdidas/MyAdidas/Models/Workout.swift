//
//  Workout.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 18.10.20.
//

import Foundation

struct WalkingWorkout {
    
    var start: Date
    var end: Date
    
    init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
  
    var duration: TimeInterval {
        return end.timeIntervalSince(start)
    }
  
    var totalEnergyBurned: Double {
        
        let walkingCaloriesPerHour: Double = 250
        let hours: Double = duration / 3600
        let totalCalories = walkingCaloriesPerHour * hours
        
        return totalCalories
    }
}
