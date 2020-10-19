//
//  Workout.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 18.10.20.
//

import Foundation

struct WorkoutInterval {
    
    var start: Date
    var end: Date
    var distance: Double
    
    init(start: Date, end: Date, distance: Double) {
        self.start = start
        self.end = end
        self.distance = distance
    }
  
    var duration: TimeInterval {
        return end.timeIntervalSince(start)
    }
  
    var totalEnergyBurned: Double {
        
        let calories: Double = 250
        let hours: Double = duration / 3600
        let totalCalories = calories * hours
        
        return totalCalories
    }
    
    
}

struct Workout {
    
    var start: Date
    var end: Date
    var intervals: [WorkoutInterval]
    
    init(with intervals: [WorkoutInterval]) {
        self.start = intervals.first!.start
        self.end = intervals.last!.end
        self.intervals = intervals
    }
    
    var totalEnergyBurned: Double {
        return intervals.reduce(0) { (result, interval) in
            result + interval.totalEnergyBurned
        }
    }
    
    var duration: TimeInterval {
        return intervals.reduce(0) { (result, interval) in
            result + interval.duration
        }
    }
    
    var distance: Double {
        return intervals.reduce(0) { (result, interval) in
            result + interval.distance
        }
    }
}
