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
    var myLat = 0.0
    var myLong = 0.0
    var latData1 = 0.0
    var longData1 = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        ref = Database.database().reference()
    }
    
    func distanceCalc(lat1: Double, long1: Double, lat2: Double, long2: Double) -> Double
    {
        var lat1rad = lat1/(180/Double.pi)
        var lat2rad = lat2/(180/Double.pi)
        var long2rad = long2/(180/Double.pi)
        var long1rad = long1/(180/Double.pi)
        return acos(sin(lat1rad)*sin(lat2rad)+cos(lat1rad)*cos(lat2rad)*cos(long2rad-long1rad)) * 3963
    }

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var coordinates: UILabel!
    @IBOutlet weak var displayTwo: UILabel!
    @IBOutlet weak var haversine: UILabel!
    
    @IBAction func download(_ sender: Any) {
        //get one of the users from the database
        ref = Database.database().reference().child("users").child("0").child("locData").child("lat")
        ref.getData(completion:  { error, snapshot in
          guard error == nil else {
            print("issue")
            return;
          }
            var latData = snapshot?.value as? Double ?? -1;
            self.latData1 = latData
            self.display.text = "other latitude: " + String(self.latData1)
            
        });
        ref = Database.database().reference().child("users").child("0").child("locData").child("long")
        ref.getData(completion:  { error, snapshot in
          guard error == nil else {
            print("issue")
            return;
          }
            var longData = snapshot?.value as? Double ?? -1;
            self.longData1 = longData
            self.displayTwo.text = "other longitude: " + String(self.longData1)
            
        });

    }
    
    func CoordToString(location : CLLocationCoordinate2D) -> String {
        return  String(format : "latitude : %f,\n longitude : %f", location.latitude, location.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] as CLLocation

        let coordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        
        myLat = Double(coordinations.latitude)
        myLong = Double(coordinations.longitude)
        
        coordinates.text = CoordToString(location: coordinations)
        
        var locData: [String: Any] = [:]
        locData["lat"] = String(format : "%f", coordinations.latitude)
        locData["long"] =  String(format : "%f", coordinations.longitude)
        var ageData: [String: Any] = [:]
        ageData["age"] = 28
        ageData["ageUpperRange"] = 35
        ageData["ageLowerRange"] = 25
        var gendData: [String: Any] = [:]
        gendData["gender"] = "Female"
        gendData["orientation"] = "Female"
        var name = "Sydney"
        let newUser = ["locData": locData,
                       "gendData": gendData,
                       "ageData": ageData,
                       "name": name
        ] as [String : Any]
        let childUpdate = ["/users/1000": newUser]
        ref = Database.database().reference()
        ref.updateChildValues(childUpdate)
        
        var distance = distanceCalc(lat1: latData1, long1: longData1, lat2: myLat, long2: myLong)
        
        self.haversine.text = "distance between us: " + String(distance)
        
        
    }
    


}

