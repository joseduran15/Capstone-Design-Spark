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
    let id = UUID()
    let name: String?
    let age: Int
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
