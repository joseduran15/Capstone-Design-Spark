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
import FirebaseStorage

class MatchViewController: UIViewController, CLLocationManagerDelegate
{
    var ref: DatabaseReference!
    let storage = Storage.storage()
    var latData1 = 0.0
    var longData1 = 0.0
    
    var currDisplayed = ""
    var me = User()
    
    //gonna change to storing all this stuff in coredata
    var liked: [String] = []
    var unLiked: [String] = []
    var matched: [String] = []
    
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
        print("in view did load \(me.id)")
    }
    
    @IBOutlet weak var display: UILabel!
    
    func displayNextUser(){
        
        print("appUsers count: \(appUsers.count)")
        if(liked.count + unLiked.count != appUsers.count)
        {
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
                
                //display other user's selfie
                let storageRef = self.storage.reference()
                self.ref = Database.database().reference().child("users").child(self.appUsers[next] ?? "error")
                self.ref.observeSingleEvent(of: .value, with: {snapshot in
                    
                    if (snapshot.hasChild("selfie"))
                    {
                        let filePath = "\(self.appUsers[next] )/selfie.jpg"
                        storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                            
                            let userPhoto = UIImage(data: data!)
                            self.imageDisplay.image = userPhoto
                        })
                    }
                })
                
                
            });
        }
        else
        {
            display.text = "No more users to display."
        }
    }
    
    
    @IBAction func matched(_ sender: Any){
        liked.append(currDisplayed)
        //upload other user id to database
        ref = Database.database().reference().child("users").child(me.id!).child("liked")
        var liked: [String : Any] = [:]
        liked[currDisplayed] = currDisplayed
        ref.updateChildValues(liked)
        //check other user's "liked list"
        showUserMatch(completion: { message in
            print("screams")
            if(message == "TRUE")
            {
                let alert = UIAlertController(title: "It's a match!", message: "Now you can message this person!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                    
                    
                }))
                self.present(alert, animated: true, completion: nil)
                //messaging between you and your new match would be enabled here
            }
            self.displayNextUser()
        })
        
    }
    
    func showUserMatch(completion: @escaping (_ message: String) -> Void)
    {
        ref = Database.database().reference().child("users").child(currDisplayed).child("liked")
        ref.observeSingleEvent(of: .value, with: {snapshot in
            
            if (snapshot.exists())
            {
                
                if(snapshot.hasChild(self.me.id!))
                {
                    var ref1 = Database.database().reference().child("users").child(self.currDisplayed).child("matched")
                    var matched: [String : Any] = [:]
                    matched[self.me.id!] = self.me.id
                    ref1.updateChildValues(matched)
                    var ref2 = Database.database().reference().child("users").child(self.me.id!).child("matched")
                    var matched2: [String : Any] = [:]
                    matched2[self.currDisplayed] = self.currDisplayed
                    ref2.updateChildValues(matched2)
                    
                    completion("TRUE")
                }
                else{
                    completion("DONE")
                }
            }
            else
            {
                completion("DONE")
            }
        })
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
            var otherName = a["name"] as! String
            if(self.me.orientation == "All" || self.me.orientation == otherGen || otherGen == "Nonbinary")
            {
                if(otherOrien == "All" || otherOrien == self.me.gender || self.me.gender == "Nonbinary")
                {
                    if((otherName == "Pikachu" || otherName == "Your") && snapshot.key != self.me.id){
                        self.appUsers.append(snapshot.key)
                    }
                    
                }
            }
            
        })
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toMapScreen")
        {
            if let nextVC = segue.destination as? ViewController
            {
                nextVC.me.name = me.name
                nextVC.me.age = me.age
                nextVC.me.gender = me.gender
                nextVC.me.orientation = me.orientation
                nextVC.me.ageLowerRange = me.ageLowerRange
                nextVC.me.ageUpperRange = me.ageUpperRange
                nextVC.me.id = me.id
            }
        }
    }

    
    
}
