//
//  API.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30.09.20.
//

import Foundation

enum API: APIProtocol {
    
    case getGoals
    
    var baseURL: URL {
        guard let url = URL(string: "https://thebigachallenge.appspot.com/_ah/api/myApi/v1/") else {
            fatalError("Base URL couldn't be configured")
        }
        
        return url
    }
    
    var path: String {
        switch self {
        case .getGoals:
            return "goals"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getGoals:
            return .GET
        }
    }
    
    var task: Task {
        switch self {
        case .getGoals:
            return .request()
        }
    }
    
}
