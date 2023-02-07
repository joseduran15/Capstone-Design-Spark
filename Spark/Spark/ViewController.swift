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
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate{
    
    struct GlobalLoc{
        static var myLat = 0.0
        static var myLong = 0.0
        
        static func distanceCalc(lat1: Double, long1: Double, lat2: Double, long2: Double) -> Double
        {
            var lat1rad = lat1/(180/Double.pi)
            var lat2rad = lat2/(180/Double.pi)
            var long2rad = long2/(180/Double.pi)
            var long1rad = long1/(180/Double.pi)
            return acos(sin(lat1rad)*sin(lat2rad)+cos(lat1rad)*cos(lat2rad)*cos(long2rad-long1rad)) * 3963
        }
    }
    
    //location data
    var locationManager = CLLocationManager()
    var ref: DatabaseReference!
    
    var latData1 = 0.0
    var longData1 = 0.0
    
    //global var to keep track of number of users in database
    var userCount = 1000
    
    //this profile's user data
    var me = User(name: "", age: 0, ageUpperRange: 0, ageLowerRange: 0, orientation: "", gender: "", latitude: GlobalLoc.myLat, longitude: GlobalLoc.myLong)

    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var haversine: UILabel!
    
    @IBOutlet weak var transButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //map initialization
        let contentView = UIHostingController(rootView: ContentView())
        contentView.view.frame = CGRectMake(20 , 170, self.view.frame.width * 0.9, self.view.frame.height * 0.3)
        view.addSubview(contentView.view)
        contentView.didMove(toParent: self)
        //database setup
        ref = Database.database().reference()
        
        var isEmpty: Bool {
            do {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
                let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
                let count  = try managedContext.count(for: request)
                return count == 0
            } catch {
                return true
            }
        }
        
        if(isEmpty)
        {
            transButton.isEnabled = true
            //deactivate the rest of this viewcontroller somehow
        }
        else
        {
            let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
            request.returnsObjectsAsFaults = false
            do {
                let result = try managedContext.fetch(request)
                for data in result as! [NSManagedObject]
            {
                me.id = data.value(forKey: "userID") as! String
                print(data.value(forKey: "userID") as! String)
              }

                   } catch {

                       print("Failed")
            }
            ref = Database.database().reference().child("users").child(me.id ?? "that's bad")
            ref.getData(completion:  {  error, snapshot in
                guard error == nil else {
                    print("issue")
                    return;
                }
                var a: [String: Any] = [:]
                //turning datasnapshot returned from database into a dictionary
                a = snapshot?.value as! Dictionary<String, Any>
                
                self.me.gender = (a["gendData"] as? [String:Any])?["gender"] as? String ?? "error"
                self.me.orientation = (a["gendData"] as? [String:Any])?["orientation"] as? String ?? "error"
                self.me.age = (a["ageData"] as? [String:Any])?["age"] as? Int ?? -1
                self.me.name = a["name"] as? String ?? "error"
                print(self.me.name)
                print(self.me.age)
                print(self.me.orientation)
                print(self.me.gender)
            });
            
            profileDataIntoDatabase()
            
            //location setup stuff
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            welcome.text = String(format:"Welcome to Spark, \(me.name ?? "help")!")
        }
        
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
    
    @IBAction func clearCoreData(_ sender: Any) {
        
        AppDelegate.sharedAppDelegate.coreDataStack.clearDatabase()
        print("ran")
        
    }
    
    
    @IBAction func download(_ sender: Any) {
        //get the first thousand users from the database
        //add a listener that will listen for changes in childcount in the database
        
        for i in 0...20
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
                
                //end here
                var otherGen = (a["gendData"] as? [String:Any])?["gender"] as? String ?? "error"
                var otherOrien = (a["gendData"] as? [String:Any])?["orientation"] as? String ?? "error"
                //print(a["name"])
                //print(otherGen)
                //print(otherOrien)
                //calculate distance between this user and other
                var distance = ViewController.GlobalLoc.distanceCalc(lat1: self.latData1, long1: self.longData1, lat2: ViewController.GlobalLoc.myLat, long2: ViewController.GlobalLoc.myLong)
                //checks if the distance is less than 2 miles and if the gender/orientation of this user and other user are compatible
                if(distance < 2 && (self.me.gender == otherOrien || otherOrien == "All") && (self.me.orientation == otherGen || self.me.orientation == "All")){
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
        
        GlobalLoc.myLat = Double(coordinations.latitude)
        GlobalLoc.myLong = Double(coordinations.longitude)
        

        var reference =  Database.database().reference().child("users").child(me.id ?? "-1").child("locData")
        
        var lat: [String: Any] = [:]
        lat["lat"] = GlobalLoc.myLat
        reference.updateChildValues(lat)
        
        reference = Database.database().reference().child("users").child(me.id ?? "-1").child("locData")
        var long: [String: Any] = [:]
        long["long"] = GlobalLoc.myLong
        reference.updateChildValues(long)
    }
    

    func childObserver()
    {
        let query = ref.child("childCount")
        
        query.observe(.value, with: { snapshot in
            
            self.userCount = snapshot.value as! Int
            print("AAAAAAAAAAAAAAAAAAAA")
        })
    }
    
    func profileDataIntoDatabase()
    {
        //putting our user's data into a dictionary format for the database
        //first location data
        var locData: [String: Any] = [:]
        locData["lat"] = String(format : "%f", GlobalLoc.myLat)
        locData["long"] =  String(format : "%f", GlobalLoc.myLong)
        //then age data
        var ageData: [String: Any] = [:]
        ageData["age"] = me.age
        ageData["ageUpperRange"] = 35
        ageData["ageLowerRange"] = 25
        //then gender/orientation data
        var gendData: [String: Any] = [:]
        gendData["gender"] = me.gender
        gendData["orientation"] = me.orientation
        var name = me.name
        //creating final dictionary
        let newUser = ["locData": locData,
                       "gendData": gendData,
                       "ageData": ageData,
                       "name": name
        ] as [String : Any]
        //putting new user into database
        var reference = Database.database().reference().child("users").childByAutoId()
        reference.setValue(newUser)
        let childautoID = reference.key
        me.id = reference.key
        //saving userID to persistant storage so when the app is open or closed it will save the profile
        let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
        let profile = NSEntityDescription.insertNewObject(forEntityName: "Profile", into: managedContext)
        profile.setValue(me.id, forKey: "userID")
        do {
            try managedContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        reference = Database.database().reference()
        var childCounter: [String: Any] = [:]
        childCounter["childCount"] = self.userCount + 1
        reference.updateChildValues(childCounter)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toMatchScreen")
        {
            if let nextVC = segue.destination as? ViewController
            {
                nextVC.me.name = me.name
                nextVC.me.age = me.age
                nextVC.me.gender = me.gender
                nextVC.me.orientation = me.orientation
                nextVC.me.ageLowerRange = me.ageLowerRange
                nextVC.me.ageUpperRange = me.ageUpperRange
            }
        }
    }

}

