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
    
    var currDisplayed = 0
    var me = User()
    
    //gonna change to storing all this stuff in coredata
    var liked: [Int] = []
    var unLiked: [Int] = []
    var notInRange: [Int] = []
    
    /*ideas for how to get compatible users from database
    - sort database somehow and grab from a range (going to SUCK to keep the ranges updated so probably not practical)
    - use the index grouping method from the firebase website: same level as users there's a gender and then an orientation and people's usernames are stored in their respective gender/orientation, and this could be expanded for interests too, then when looking for a potential match you look in the gender/orientation group https://firebase.google.com/docs/database/ios/structure-data#fanout
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(ViewController.GlobalLoc.myLat)
        print(ViewController.GlobalLoc.myLong)
        ref = Database.database().reference()
        var next = Int.random(in: 0..<999)
        while(notInRange.contains(next) || unLiked.contains(next) || liked.contains(next))
        {
            next = Int.random(in: 0..<999)
        }
        displayNextUser(otherID: next)
    }
    
    @IBOutlet weak var display: UILabel!
    
    func displayNextUser(otherID: Int){
        ref = Database.database().reference().child("users").child(
            String(otherID))
        currDisplayed = otherID
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
            var otherName = a["name"]
            //calculate distance between this user and other
            var distance = ViewController.GlobalLoc.distanceCalc(lat1: self.latData1, long1: self.longData1, lat2: ViewController.GlobalLoc.myLat, long2: ViewController.GlobalLoc.myLong)
            //checks if the distance is less than 2 miles and if the gender/orientation of this user and other user are compatible
            /*if(distance < 2 && (self.me.gender == otherOrien || otherOrien == "All") && (self.me.orientation == otherGen || self.me.orientation == "All")){
                self.display.text = otherGen
            }
            else if (distance > 50)
            {
                self.notInRange.append(otherID)
            }*/
            
            self.display.text = otherName as! String
            
            
        });
    }
    
    
    @IBAction func matched(_ sender: Any){
        liked.append(currDisplayed)
        var next = Int.random(in: 0..<999)
        while(notInRange.contains(next) || unLiked.contains(next) || liked.contains(next))
        {
            next = Int.random(in: 0..<999)
        }
        displayNextUser(otherID: next)
    }
    
    @IBAction func noMatch(_ sender: Any){
        unLiked.append(currDisplayed)
        var next = Int.random(in: 0..<999)
        while(notInRange.contains(next) || unLiked.contains(next) || liked.contains(next))
        {
            next = Int.random(in: 0..<999)
        }
        displayNextUser(otherID: next)
        
    }
    
    @IBAction func testingMethod(_ sender: Any) {
        var next = Int.random(in: 0..<999)
        while(notInRange.contains(next) || unLiked.contains(next) || liked.contains(next))
        {
            next = Int.random(in: 0..<999)
        }
        displayNextUser(otherID: next)
    }
    
    
}
