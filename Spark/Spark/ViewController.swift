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
import FirebaseStorage
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
    let storage = Storage.storage()
    
    var latData1 = 0.0
    var longData1 = 0.0
    
    //global var to keep track of number of users in database
    var userCount = 1000
    
    var loaded = false
    
    //this profile's user data
    var me = User(name: "", age: 0, ageUpperRange: 0, ageLowerRange: 0, orientation: "", gender: "", latitude: GlobalLoc.myLat, longitude: GlobalLoc.myLong)

    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var haversine: UILabel!
    @IBOutlet weak var transButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //database setup
        ref = Database.database().reference()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        //print(UserDefaults.standard.bool(forKey: "LOADED"))
        if (UserDefaults.standard.bool(forKey: "LOADED") == false)
        {
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
                
                //a ui alert will pop up saying that you must create a profile, when you click ok you go to profile view controller
                transButton.isEnabled = true
                let alert = UIAlertController(title: "You do not have a profile", message: "Please create a profile to continue using the app", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "To Profile Creation", style: .default, handler: { action in
                    self.transButton.sendActions(for: .touchUpInside)
                    
                }))
                self.present(alert, animated: true, completion: nil)
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
                //where the stuff now in setup is
                
                setup(completion: {message in
                    self.welcome.text = String(format:"Welcome to Spark, \(self.me.name ?? "help")!")
                })
                
                //location setup stuff
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
                UserDefaults.standard.set(true, forKey: "LOADED")
                
            }
        }
        else
        {
            welcome.text = String(format:"Welcome to Spark, \(self.me.name ?? "help")!")
        }
            //map initialization
        let contentView = UIHostingController(rootView: ContentView())
        contentView.view.frame = CGRectMake(20 , 170, self.view.frame.width * 0.9, self.view.frame.height * 0.3)
        view.addSubview(contentView.view)
        contentView.didMove(toParent: self)
        
        
    }
    
    func setup(completion: @escaping (_ message: String) -> Void)
    {
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
            self.me.age = Int((a["ageData"] as? [String:Any])?["age"] as? String ?? "-1") ?? -5
            self.me.name = a["name"] as? String ?? "error"
            self.me.ageUpperRange = (a["ageData"] as? [String:Any])?["ageUpperRange"] as? Int ?? -5
            self.me.ageLowerRange = (a["ageData"] as? [String:Any])?["ageLowerRange"] as? Int ?? -5
            UserDefaults.standard.set(self.me.name, forKey: "NAME")
            UserDefaults.standard.set(self.me.age, forKey: "AGE")
            UserDefaults.standard.set(self.me.gender, forKey: "GENDER")
            UserDefaults.standard.set(self.me.orientation, forKey: "ORIENTATION")
            UserDefaults.standard.set(self.me.id, forKey: "UID")
            
            
            completion("DONE")
        });
        
    }
    
    @IBAction func deactivateForTesting(_ sender: Any) {
        AppDelegate.sharedAppDelegate.coreDataStack.clearDatabase()
        locationManager.stopUpdatingLocation()
        UserDefaults.standard.set(false, forKey: "LOADED")
        transButton.isEnabled = true
        let alert = UIAlertController(title: "You do not have a profile", message: "Please create a profile to continue using the app", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "To Profile Creation", style: .default, handler: { action in
            self.transButton.sendActions(for: .touchUpInside)
            
        }))
        self.present(alert, animated: true, completion: nil)
        print("ran")
    }
    
    
    @IBAction func clearCoreData(_ sender: Any) {
        
        AppDelegate.sharedAppDelegate.coreDataStack.clearDatabase()
       
        ref = Database.database().reference().child("users").child(me.id ?? "that's bad").child("matched")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            if(snapshot.exists())
            {
                //need to get a list of everyone you've matched with, go through that list and remove you from their matched list and then delete their conversatoin with you if there is one
            }
        })
        //then take your userid and use it to delete your selfie from firestore
        ref = Database.database().reference().child("users").child(me.id!)
        let storageRef = storage.reference()
        ref.observeSingleEvent(of: .value, with: {snapshot in
                
            if (snapshot.hasChild("selfie"))
            {
                    let filePath = "\(self.me.id ?? "god" )/selfie.jpg"
                    
                    storageRef.child(filePath).delete { error in
                        if let error = error {
                            print(error)
                        } else {
                            // File deleted successfully
                        }
                        
                    }
                }
            })
        //this would remove your branch - this will happen last
        //ref = Database.database().reference().child("users").child(me.id ?? "that's bad")
        //ref.removeValue()
        //stop location manager
        locationManager.stopUpdatingLocation()
        UserDefaults.standard.set(false, forKey: "LOADED")
        transButton.isEnabled = true
        let alert = UIAlertController(title: "You do not have a profile", message: "Please create a profile to continue using the app", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "To Profile Creation", style: .default, handler: { action in
            self.transButton.sendActions(for: .touchUpInside)
            
        }))
        self.present(alert, animated: true, completion: nil)
        print("ran")
        
    }
    
    
    @IBAction func download(_ sender: Any) {
        
        //display a user's matches
        
        ref = Database.database().reference().child("users").child(me.id!).child("matched")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            if(snapshot.exists())
            {
                var a: [String: Any] = [:]
                a = snapshot.value as! Dictionary<String, Any>
                a.values.forEach {id in
                    self.haversine.text = String(format: self.haversine.text! + "\nYou matched with \(id)")
                }
            }
            
            
        })

    }
    
    //runs constantly to get user's updated location and put it in the database
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toMatchScreen")
        {
            if let nextVC = segue.destination as? MatchViewController
            {
                nextVC.me = me
            }
        }
        if(segue.identifier == "toSettings")
        {
            if let nextVC = segue.destination as? SettingsViewController
            {
                nextVC.me = me
            }
        }
        if(segue.identifier == "toMessageScreen")
        {
            if let nextVC = segue.destination as? MessageViewController
            {
                nextVC.me = me
            }
        }
    }

}

