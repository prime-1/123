//
//  UserGPS.swift
//  ModelApp
//
//  Created by Chan* on 2016/10/12.
//  Copyright © 2016年 SakuraiLabcchan3_dev. All rights reserved.
//

import Foundation
import RealmSwift

class AllGPS: Object {
    dynamic var name = ""
    dynamic var sex : String = ""
    dynamic var age : Int64 = 0
    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    dynamic var altitude: Double = 0
    dynamic var horiacc: Double = 0
    dynamic var createdAt : String = ""
    dynamic var span : Double = 0
    dynamic var distance : Double = 0
    dynamic var speed : Double = 0
}

class HighAccGPS: Object {
    dynamic var name = ""
    dynamic var sex : String = ""
    dynamic var age : Int64 = 0
    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    dynamic var altitude: Double = 0
    dynamic var horiacc: Double = 0
    dynamic var createdAt : String = ""
    dynamic var span : Double = 0
    dynamic var distance : Double = 0
    dynamic var speed : Double = 0
}

class ALLFilterGPS: Object {
    dynamic var name = ""
    dynamic var sex : String = ""
    dynamic var age : Int64 = 0
    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    dynamic var altitude: Double = 0
    dynamic var horiacc: Double = 0
    dynamic var createdAt : String = ""
    dynamic var span : Double = 0
    dynamic var distance : Double = 0
    dynamic var speed : Double = 0
}
