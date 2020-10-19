//
//  WorkoutViewModel.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 18.10.20.
//

import Foundation
import CoreLocation

class WorkoutViewModel {
    
    var updateUI: (() -> Void)?
    
    var item: Item
    
    var session = WorkoutSession()
    
    var timer: Timer!
    
    var distance = 0.0
    var pace = 0.0
    
    lazy var locations = [CLLocation]()
    
    init(_ item: Item) {
        self.item = item
    }
    
}
