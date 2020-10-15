//
//  Gradient.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 15.10.20.
//

import UIKit

enum Gradient: String {
    
    case red
    case blue
    case green
    case grey
    case error
    
    var start: UIColor {
        guard
            let color = UIColor(named: "gradient_\(self.rawValue)_start")
        else {
            return .lightGray
        }
        
        return color
    }
    
    var end: UIColor {
        guard
            let color = UIColor(named: "gradient_\(self.rawValue)_end")
        else {
            return .darkGray
        }
        
        return color
    }
    
    static func colors(for item: Item?) -> Gradient {
        
        guard let item = item else {
            return .grey
        }
        
        switch item.type {
        case .step:
            return .red
        case .walking:
            return .green
        case .running:
            return .blue
        }
    }
    
}
