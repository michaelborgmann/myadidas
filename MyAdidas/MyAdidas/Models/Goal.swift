//
//  Goal.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30.09.20.
//

import Foundation

enum Trophy: String, Codable {
    case gold = "gold_medal"
    case silver = "silver_medal"
    case bronze = "bronze_medal"
    case zombie = "zombie_hand"
}

struct Reward: Codable {
    var trophy: Trophy
    var points: Int
}

enum Type: String, Codable {
    case step = "step"
    case walking = "walking_distance"
    case running = "running_distance"
    
    var imageName: String {
        switch self {
        case .step:
            return "steps_04"
        case .walking:
            return "walking_02"
        case .running:
            return "running_02"
        }
    }
}

struct Item: Codable {
    var id: String
    var title: String
    var description: String
    var type: Type
    var goal: Int
    var reward: Reward
}

struct Goal: Codable {
    var items: [Item]
    var nextPageToken: String
}
