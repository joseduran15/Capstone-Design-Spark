//
//  ViewController.swift
//  Spark
//
//  Created by Alex Kazaglis on 10/29/22.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseCore
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import FirebaseDatabase
import FirebaseDatabaseSwift

class ViewController: UIViewController, CLLocationManagerDelegate{
    
    var locationManager = CLLocationManager()
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        ref = Database.database().reference()
    }

    @IBOutlet weak var coordinates: UILabel!
    
    
    func CoordToString(location : CLLocationCoordinate2D) -> String {
        return  String(format : "latitude : %f,\n longitude : %f", location.latitude, location.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] as CLLocation

        let coordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        
        coordinates.text = CoordToString(location: coordinations)
        
        var dataDictionary: [String: Any] = [:]
        dataDictionary["Lat"] = String(format : "%f", coordinations.latitude)
        dataDictionary["Long"] =  String(format : "%f", coordinations.longitude)
        ref.setValue(dataDictionary)
        
        
    }
    


}

