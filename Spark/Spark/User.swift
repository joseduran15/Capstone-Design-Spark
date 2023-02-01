//
//  User.swift
//  UserLocationSpark
//
//  Created by Jay Samaraweera on 12/4/22.
//

import Foundation
import SwiftUI
import MapKit

//class User: NSObject, MKAnnotation {
//    let name: String?
//    let age: Int
//    let coordinate: CLLocationCoordinate2D
//
//    init(name: String, age: Int, coordinate: CLLocationCoordinate2D) {
//        self.name = name
//        self.age = age
//        self.coordinate = coordinate
//
//        super.init()
//    }
//}

struct User: Identifiable {
    var id: String? = nil
    var name: String? = nil
    var age: Int = 0
    var ageUpperRange: Int = 0
    var ageLowerRange: Int = 0
    var orientation: String? = nil
    var gender: String? = nil
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
