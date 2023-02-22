//
//  MatchViewController.swift
//  Spark
//
//  Created by Alex Kazaglis on 1/28/23.
//

import Foundation
import UIKit
import CoreLocation
import FirebaseCore
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import FirebaseDatabase
import FirebaseDatabaseSwift

class MatchViewController: UIViewController, CLLocationManagerDelegate
{
    var ref: DatabaseReference!
    var latData1 = 0.0
    var longData1 = 0.0
    
    var currDisplayed = ""
    var me = User()
    
    //gonna change to storing all this stuff in coredata
    var liked: [String] = []
    var unLiked: [String] = []
    
    var appUsers: [String] = []
    
    @IBOutlet weak var imageDisplay: UIImageView!
    
    
    /*ideas for how to get compatible users from database
    - use the index grouping method from the firebase website: same level as users there's a gender and then an orientation and people's usernames are stored in their respective gender/orientation, and this could be expanded for interests too, then when looking for a potential match you look in the gender/orientation group https://firebase.google.com/docs/database/ios/structure-data#fanout
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(ViewController.GlobalLoc.myLat)
        print(ViewController.GlobalLoc.myLong)
        ref = Database.database().reference()
        userObserver()
    }
    
    @IBOutlet weak var display: UILabel!
    
    func displayNextUser(){
        
        /*appUsers.append("9")
        appUsers.append("18")
        appUsers.append("784")*/
        print("appUsers count: \(appUsers.count)")
        var next = Int.random(in: 0..<appUsers.count)
        while(unLiked.contains(appUsers[next]) || liked.contains(appUsers[next]))
        {
            next = Int.random(in: 0..<appUsers.count)
        }
        currDisplayed = appUsers[next]
        print("appUsers[next]: \(appUsers[next])")
        ref = Database.database().reference().child("users").child(appUsers[next])
        ref.observeSingleEvent(of: .value, with: { snapshot in 
            var a: [String: Any] = [:]
            //turning datasnapshot returned from database into a dictionary
            a = snapshot.value as! Dictionary<String, Any>
            print("a: \(a)")
            //assigning values from the dictionary to variables so we don't have to type all the necessary error stuff every time
            self.latData1 = (a["locData"] as? [String:Any])?["lat"] as? Double ?? -1
            self.longData1 = (a["locData"] as? [String:Any])?["long"] as? Double ?? -1
            
            var otherGen = (a["gendData"] as? [String:Any])?["gender"] as? String ?? "error"
            var otherOrien = (a["gendData"] as? [String:Any])?["orientation"] as? String ?? "error"
            var otherName = a["name"]
            //calculate distance between this user and other
            var distance = ViewController.GlobalLoc.distanceCalc(lat1: self.latData1, long1: self.longData1, lat2: ViewController.GlobalLoc.myLat, long2: ViewController.GlobalLoc.myLong)
            //checks if the distance is less than 2 miles
            
            self.display.text = otherName as? String
            print("othername: \(otherName)")
            
            //display other user's selfie
            
            
        });
    }
    
    
    @IBAction func matched(_ sender: Any){
        liked.append(currDisplayed)
        displayNextUser()
    }
    
    @IBAction func noMatch(_ sender: Any){
        unLiked.append(currDisplayed)
        displayNextUser()
        
    }
    
    @IBAction func testingMethod(_ sender: Any) {
        displayNextUser()
    }
    
    func userObserver()
    {
        ref.child("users").observe(DataEventType.childAdded, with: { snapshot in
            
            var a: [String: Any] = [:]
            //turning datasnapshot returned from database into a dictionary
            a = snapshot.value as! Dictionary<String, Any>
            var otherGen = (a["gendData"] as? [String:Any])?["gender"] as? String ?? "error"
            var otherOrien = (a["gendData"] as? [String:Any])?["orientation"] as? String ?? "error"
            if(self.me.orientation == "All" || self.me.orientation == otherGen || otherGen == "Nonbinary")
            {
                if(otherOrien == "All" || otherOrien == self.me.gender || self.me.gender == "Nonbinary")
                {
                    self.appUsers.append(snapshot.key)
                    print(snapshot.key)
                    print(otherGen)
                    print(otherOrien)
                    
                }
            }
            print("it ran")
            
        })
        
        
    }
    
    
}
