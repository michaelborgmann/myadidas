//
//  WorkoutViewModel.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 18.10.20.
//

import Foundation

class WorkoutViewModel {
    
    var updateUI: (() -> Void)?
    
    var item: Item
    
    var session = WorkoutSession()
    
    var timer: Timer!
    
    init(_ item: Item) {
        self.item = item
    }
    
}
