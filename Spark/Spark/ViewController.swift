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
    
    //profile data
    var myName = ""
    var myAge = -1
    var myGender = ""
    var myOrientation = ""
    var myUserID = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        ref = Database.database().reference()
        welcome.text = String(format:"Welcome to Spark, \(myName)!")
    }
    
    func distanceCalc(lat1: Double, long1: Double, lat2: Double, long2: Double) -> Double
    {
        var lat1rad = lat1/(180/Double.pi)
        var lat2rad = lat2/(180/Double.pi)
        var long2rad = long2/(180/Double.pi)
        var long1rad = long1/(180/Double.pi)
        return acos(sin(lat1rad)*sin(lat2rad)+cos(lat1rad)*cos(lat2rad)*cos(long2rad-long1rad)) * 3963
    }

    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var haversine: UILabel!
    
    @IBAction func download(_ sender: Any) {
        //get the first ten of the users from the database
        for i in 0...1000
        {
            ref = Database.database().reference().child("users").child(String(i))
            ref.getData(completion:  { error, snapshot in
                guard error == nil else {
                    print("issue")
                    return;
                }
                var a: [String: Any] = [:]
                a = snapshot?.value as! Dictionary<String, Any>
                self.latData1 = (a["locData"] as? [String:Any])?["lat"] as? Double ?? -1
                self.longData1 = (a["locData"] as? [String:Any])?["long"] as? Double ?? -1
                var otherGen = (a["gendData"] as? [String:Any])?["gender"] as? String ?? "error"
                var otherOrien = (a["gendData"] as? [String:Any])?["orientation"] as? String ?? "error"
                var distance = self.distanceCalc(lat1: self.latData1, long1: self.longData1, lat2: self.myLat, long2: self.myLong)
                if(distance < 3 && (self.myGender == otherOrien || otherOrien == "All") && (self.myOrientation == otherGen || self.myOrientation == "All")){
                    self.haversine.text = String(format: self.haversine.text! + "\n distance between you and \(a["name"] ?? "error") : %f",distance)
                }
                
                
            });
        }

    }
    
    func CoordToString(location : CLLocationCoordinate2D) -> String {
        return  String(format : "our latitude : %f,\n our longitude : %f", location.latitude, location.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] as CLLocation

        let coordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        
        myLat = Double(coordinations.latitude)
        myLong = Double(coordinations.longitude)
        
        var locData: [String: Any] = [:]
        locData["lat"] = String(format : "%f", coordinations.latitude)
        locData["long"] =  String(format : "%f", coordinations.longitude)
        var ageData: [String: Any] = [:]
        ageData["age"] = myAge
        ageData["ageUpperRange"] = 35
        ageData["ageLowerRange"] = 25
        var gendData: [String: Any] = [:]
        gendData["gender"] = myGender
        gendData["orientation"] = myOrientation
        var name = myName
        let newUser = ["locData": locData,
                       "gendData": gendData,
                       "ageData": ageData,
                       "name": name
        ] as [String : Any]
        let childUpdate = ["/users/1000": newUser]
        ref = Database.database().reference()
        ref.updateChildValues(childUpdate)
        
        
    }
    


}

