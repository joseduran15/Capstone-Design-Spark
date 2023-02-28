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
    
    //this profile's user data
    var me = User(name: "", age: 0, ageUpperRange: 0, ageLowerRange: 0, orientation: "", gender: "", latitude: GlobalLoc.myLat, longitude: GlobalLoc.myLong)

    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var haversine: UILabel!
    @IBOutlet weak var transButton: UIButton!
    
    @IBOutlet weak var imageViewForTesting: UIImageView!
    
    
    
    
    
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
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
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
                    //put photo stuff here and see if that helps idk
            })
            
            //location setup stuff
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
            
           
        }
        
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
            completion("DONE")
        });
        
    }
    
    @IBAction func clearCoreData(_ sender: Any) {
        
        AppDelegate.sharedAppDelegate.coreDataStack.clearDatabase()
        print("ran")
        
    }
    
    
    @IBAction func download(_ sender: Any) {
        //get the first thousand users from the database
        
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
                var otherGen = (a["gendData"] as? [String:Any])?["gender"] as? String ?? "error"
                var otherOrien = (a["gendData"] as? [String:Any])?["orientation"] as? String ?? "error"
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toMatchScreen")
        {
            if let nextVC = segue.destination as? MatchViewController
            {
                nextVC.me.name = me.name
                nextVC.me.age = me.age
                nextVC.me.gender = me.gender
                nextVC.me.orientation = me.orientation
                nextVC.me.ageLowerRange = me.ageLowerRange
                nextVC.me.ageUpperRange = me.ageUpperRange
                nextVC.me.id = me.id
                print("in prepare for segue  \(me.id)")
            }
        }
    }

}

