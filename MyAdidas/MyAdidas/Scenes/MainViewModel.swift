//
//  ViewModel.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30.09.20.
//

import Foundation
import RealmSwift

class MainViewModel {
    
    var goals: Goal?
    
    func persist() {
        guard let goals = goals else {
            return
        }
        
        do {
            let realm = try Realm()
            
            // NOTE: po realm.configuration.fileURL?.absoluteString
            debugPrint(try Realm().configuration.fileURL!.absoluteString)
            
            Goal.delete()
                
            try realm.write {
                realm.add(goals)
            }
            
        } catch {
            fatalError("Cannot persist goals")
        }
    }
    
}
