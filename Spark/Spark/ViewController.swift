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
import SwiftUI

class ViewController: UIViewController, CLLocationManagerDelegate{
    
    //location data
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
        let contentView = UIHostingController(rootView: ContentView())
        contentView.view.frame = view.bounds
        view.addSubview(contentView.view)
        contentView.didMove(toParent: self)
        //location setup stuff
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //database setup
        ref = Database.database().reference()
        welcome.text = String(format:"Welcome to Spark, \(myName)!")
        
        var locations: [CLLocation] = []

                // ...and fill it with CLLocation objects
                locations.append(CLLocation(latitude: 48.1623, longitude: 11.5798))
                locations.append(CLLocation(latitude: 48.1621, longitude: 11.5799))
                locations.append(CLLocation(latitude: 48.1603, longitude: 11.5763))
                locations.append(CLLocation(latitude: 48.1622, longitude: 11.5797))
               
                
                let dbscan = DBSCAN(locations)
                let (sequence, places) = dbscan.findCluster(eps: 75.0, minPts: 0)
                
                print(sequence)
                print(places)
    }
    
    //calculates distance between two pairs of latitudes and longitudes
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
        //get the first thousand users from the database
        for i in 0...1000
        {
            //points reference to current user we want to get from database
            ref = Database.database().reference().child("users").child(String(i))
            ref.getData(completion:  { error, snapshot in
                guard error == nil else {
                    print("issue")
                    return;
                }
                var a: [String: Any] = [:]
                //turning datasnapshot returned from database into a dictionary
                a = snapshot?.value as! Dictionary<String, Any>
                //assigning values from the dictionary to variables so we don't have to type all the necessary error stuff every time
                self.latData1 = (a["locData"] as? [String:Any])?["lat"] as? Double ?? -1
                self.longData1 = (a["locData"] as? [String:Any])?["long"] as? Double ?? -1
                var otherGen = (a["gendData"] as? [String:Any])?["gender"] as? String ?? "error"
                var otherOrien = (a["gendData"] as? [String:Any])?["orientation"] as? String ?? "error"
                //calculate distance between this user and other
                var distance = self.distanceCalc(lat1: self.latData1, long1: self.longData1, lat2: self.myLat, long2: self.myLong)
                //checks if the distance is less than 2 miles and if the gender/orientation of this user and other user are compatible
                if(distance < 2 && (self.myGender == otherOrien || otherOrien == "All") && (self.myOrientation == otherGen || self.myOrientation == "All")){
                    self.haversine.text = String(format: self.haversine.text! + "\n distance between you and \(a["name"] ?? "error") : %f",distance)
                }
                
                
            });
        }

    }
    
    //runs constantly to get user's updated location and put it in the database and also puts profile stuff from former view into database, in the future profile stuff will be in a different method to save calls to database but this is easiest for now
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //gets this user's location
        let userLocation:CLLocation = locations[0] as CLLocation

        //puts coordinates into usable format
        let coordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        
        myLat = Double(coordinations.latitude)
        myLong = Double(coordinations.longitude)
        
        //putting our user's data into a dictionary format for the database
        //first location data
        var locData: [String: Any] = [:]
        locData["lat"] = String(format : "%f", coordinations.latitude)
        locData["long"] =  String(format : "%f", coordinations.longitude)
        //then age data
        var ageData: [String: Any] = [:]
        ageData["age"] = myAge
        ageData["ageUpperRange"] = 35
        ageData["ageLowerRange"] = 25
        //then gender/orientation data
        var gendData: [String: Any] = [:]
        gendData["gender"] = myGender
        gendData["orientation"] = myOrientation
        var name = myName
        //creating final dictionary
        let newUser = ["locData": locData,
                       "gendData": gendData,
                       "ageData": ageData,
                       "name": name
        ] as [String : Any]
        //putting new user into database
        let childUpdate = ["/users/1000": newUser]
        ref = Database.database().reference()
        ref.updateChildValues(childUpdate)
        
        
    }
    


}

