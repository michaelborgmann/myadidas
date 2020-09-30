//
//  Service.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30.09.20.
//

import Foundation


struct Service {
    
    private static let api = Networking<API>()
 
    static func fetchGoals(completion: @escaping ((_ result: Goal) -> Void)) {
        api.request(api: .getGoals, type: Goal.self) { goal in
            completion(goal)
        }
    }
    
}
