//
//  Goal.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30.09.20.
//

import Foundation
import RealmSwift

enum Trophy: String, Codable {
    case gold = "gold_medal"
    case silver = "silver_medal"
    case bronze = "bronze_medal"
    case zombie = "zombie_hand"
    
    var imageName: String {
        switch self {
        case .gold:
            return "gold_star"
        case .silver:
            return "silver_star"
        case .bronze:
            return "bronze_star"
        case .zombie:
            return "zombie_hand"
        }
    }
}

class Reward: Object, Codable {
    
    @objc dynamic var _trophy: Trophy.RawValue
    @objc dynamic var points: Int
    
    var trophy: Trophy {
        get { Trophy(rawValue: _trophy)! }
    }
    
    enum CodingKeys: String, CodingKey {
        case _trophy = "trophy"
        case points = "points"
    }
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

class Item: Object, Codable {
    
    @objc dynamic var id: String
    @objc dynamic var title: String
    @objc dynamic var details: String
    @objc dynamic var _type: Type.RawValue
    @objc dynamic var goal: Int
    @objc dynamic var reward: Reward?
    
    var type: Type {
        get { Type(rawValue: _type)! }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case details = "description"
        case _type = "type"
        case goal = "goal"
        case reward = "reward"
    }
    
}

class Goal: Object, Codable {
    var items = List<Item>()
    @objc dynamic var nextPageToken: String = ""
    
    enum CodingKeys: String, CodingKey {
        case items = "items"
        case nextPageToken = "nextPageToken"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.nextPageToken = try container.decode(String.self, forKey: .nextPageToken)
        
        let itemsArray = try container.decode([Item].self, forKey: .items)
        items.append(objectsIn: itemsArray)
        
    }
    
    static func persisted() -> Results<Goal> {
        
        do {
            let realm = try Realm()
            
            return realm.objects(Goal.self)
            
        } catch {
            fatalError("Cannot get persisted REALM")
        }
        
    }
    
    static func delete() {
        
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.deleteAll()
            }
            
        } catch {
            fatalError("Cannot delete REALM")
        }
        
    }
    
}
