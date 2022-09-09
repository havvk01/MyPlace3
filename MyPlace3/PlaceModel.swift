//
//  PlaceModel.swift
//  MyPlace3
//
//  Created by Slava Havvk on 03.09.2022.
//

import Foundation
import RealmSwift
//import UIKit

class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location:String?
    @objc dynamic var type:String?
    @objc dynamic var imageData:Data?
    @objc dynamic var date = Date()
    @objc dynamic var rating: Double = 0.0
    
    convenience init(name:String, location:String?, type:String?, imageData:Data?, rating:Double) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
        
    }
    
}
