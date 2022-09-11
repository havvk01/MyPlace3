//
//  StorageManager.swift
//  MyPlace3
//
//  Created by Slava Havvk on 05.09.2022.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            //print(Realm.Configuration.defaultConfiguration.fileURL)
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place:Place) {
        
        try! realm.write {
            realm.delete(place)
        }
    }
}
