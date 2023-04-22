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
    
    var currDisplayed = ""
    var currDisplayedName = ""
    var me = User()
    
    //gonna change to storing all this stuff in coredata
    var liked: [String] = []
    var unLiked: [String] = []
    var matched: [String] = []
    
    var appUsers: [String] = []
    
    //labels
    let nameLabel = UILabel(frame: CGRect(x: 16, y: 379, width: 358, height: 81))
    let ageGenLabel = UILabel(frame: CGRect(x: 43, y: 468, width: 308, height: 70))
    let descripLabel = UILabel(frame: CGRect(x: 16, y: 546, width: 358, height: 155))
    
    @IBOutlet weak var imageDisplay: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        /*makeMatchedList(completion: {message in
            print(self.matched)
        })*/
        userObserver(completion: {message in
            self.displayNextUser()
        })
        createLabels()
        
        
        
        
    }
    
    func createLabels()
    {
        
        nameLabel.text = "Nothing yet"
        nameLabel.myLabel()
        nameLabel.font = UIFont(name: "Avenir-Black", size: 31)
        view.addSubview(nameLabel)
        ageGenLabel.text = "Nothing yet"
        ageGenLabel.myLabel()
        view.addSubview(ageGenLabel)
        descripLabel.text = "Nothing yet"
        descripLabel.myLabel()
        descripLabel.numberOfLines = 4
        view.addSubview(descripLabel)
    }
    
    func displayNextUser(){
        
        print("appUsers count: \(appUsers.count)")
        if(liked.count + unLiked.count != appUsers.count)
        {
            var next = Int.random(in: 0..<appUsers.count)
            while(unLiked.contains(appUsers[next]) || liked.contains(appUsers[next]))
            {
                next = Int.random(in: 0..<appUsers.count)
                //check if next exists in the database, if it doesn't remove it from appUsers
                /*if let index = appUsers.firstIndex(of: appUsers[next])
                {
                    appUsers.remove(at: index)
                }*/
            }
            imageDisplay.image = nil
            currDisplayed = appUsers[next]
            ref = Database.database().reference().child("users").child(appUsers[next])
            ref.observeSingleEvent(of: .value, with: { snapshot in
                var a: [String: Any] = [:]
                //turning datasnapshot returned from database into a dictionary
                a = snapshot.value as! Dictionary<String, Any>
                //assigning values from the dictionary to variables so we don't have to type all the necessary error stuff every time
                var otherGen = (a["gendData"] as? [String:Any])?["gender"] as? String ?? "error"
                var otherOrien = (a["gendData"] as? [String:Any])?["orientation"] as? String ?? "error"
                var otherAge = (a["ageData"] as? [String:Any])?["age"] as? String ?? "error"
                var otherName = a["name"]
                var otherBio = a["bio"]
                var drink = a["drinkData"] as? [String]
                self.currDisplayedName = otherName as! String
                
                self.nameLabel.text = otherName as? String
                self.ageGenLabel.text = "\(otherAge) years old \n\(otherGen)\n"
               // self.descripLabel.text = "\(otherBio ?? "no bio")\nideas for a drink to buy me: \(drink![0])"
                self.descripLabel.text = "\(otherBio ?? "no bio")\nideas for a drink to buy me: "
                if(drink != nil){
                    for x in drink!
                    {
                        self.descripLabel.text! += x
                        self.descripLabel.text! += " "
                    }
                }
                
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
            nameLabel.text = "No more users to display."
            ageGenLabel.text = ""
            descripLabel.text = ""
            imageDisplay.image = nil
            
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
            if(message == "TRUE")
            {
                let alert = UIAlertController(title: "It's a match!", message: "Now you can message this person!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                    
                    
                }))
                self.present(alert, animated: true, completion: nil)
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
                    matched[self.me.id!] = self.me.name
                    ref1.updateChildValues(matched)
                    var ref2 = Database.database().reference().child("users").child(self.me.id!).child("matched")
                    var matched2: [String : Any] = [:]
                    matched2[self.currDisplayed] = self.currDisplayedName
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
    
    /*func makeMatchedList(completion: @escaping (_ message: String) -> Void)
    {
        print("method started")
        ref = Database.database().reference().child("users").child(me.id!).child("matched")
        ref.observeSingleEvent(of: .value, with: {snapshot in
            
            if (snapshot.exists())
            {
                print("inside snapshot exists")
                var a: [String: Any] = [:]
                //turning datasnapshot returned from database into a dictionary
                a = snapshot.value as! Dictionary<String, Any>
                a.keys.forEach {id in
                    self.matched.append(id)
                    print(id)
                }
                
            }
            print("completion block")
            completion("DONE")
        })
    }*/
    
    func userObserver(completion: @escaping (_ message: String) -> Void)
    {
        ref.child("users").observe(DataEventType.childAdded, with: { snapshot in
            
            var a: [String: Any] = [:]
            //turning datasnapshot returned from database into a dictionary
            a = snapshot.value as! Dictionary<String, Any>
            print(snapshot.key)
            print("hello")
            if(a["name"] != nil)
            {
                var otherGen = (a["gendData"] as? [String:Any])?["gender"] as? String ?? "error"
                var otherOrien = (a["gendData"] as? [String:Any])?["orientation"] as? String ?? "error"
                var latData1 = (a["locData"] as? [String:Any])?["lat"] as? Double ?? -1
                var longData1 = (a["locData"] as? [String:Any])?["long"] as? Double ?? -1
                var otherName = a["name"] as! String
                //calculate distance between this user and other
                var distance = ViewController.GlobalLoc.distanceCalc(lat1: latData1, long1: longData1, lat2: ViewController.GlobalLoc.myLat, long2: ViewController.GlobalLoc.myLong)
                //checks if the distance is less than 2 miles
                if(distance <= 5)
                {
                    print("distance")
                    if(self.me.orientation == "All" || self.me.orientation == otherGen || otherGen == "Nonbinary")
                    {
                        print("orientation")
                        
                        if(otherOrien == "All" || otherOrien == self.me.gender || self.me.gender == "Nonbinary")
                        {
                            print("gender")
                            
                            if(snapshot.key != self.me.id && snapshot.key.starts(with: "-")){
                                self.appUsers.append(snapshot.key)
                                print(self.appUsers)
                                print("hiiiiiiiiiiiiiiiiiii")
                                completion("DONE")
                            }
                        }
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
                nextVC.me = me
            }
        }
    }

    
    
}
extension UILabel {
    func myLabel() {
        textAlignment = .center
        textColor = .white
        backgroundColor = .clear
        font = UIFont(name: "Avenir", size: 21)
        numberOfLines = 2
        lineBreakMode = .byCharWrapping
        //sizeToFit()
    }
}

