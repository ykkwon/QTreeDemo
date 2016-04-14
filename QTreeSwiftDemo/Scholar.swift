//
//  Scholar.swift
//  WWDC Scholars 2015
//
//  Created by Gelei Chen on 15/5/20.
//  Copyright (c) 2015 WWDC-Scholars. All rights reserved.
//

import Foundation

class Scholar:NSObject{
    
    var name : String?
    var longitude : Double
    var latitude : Double
    var location: String
    
    init(name:String?,latitude:Double,longitude:Double,location:String){
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
        self.location = location
    }
    
}