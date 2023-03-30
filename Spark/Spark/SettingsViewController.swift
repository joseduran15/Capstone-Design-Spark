//
//  SettingsViewController.swift
//  Spark
//
//  Created by Alex Kazaglis on 3/4/23.
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
import Foundation

class SettingsViewController: UIViewController
{
    
    var me = User()
    var ref: DatabaseReference!
    let storage = Storage.storage()
    
    @IBOutlet weak var displayProfile: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var bioLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference().child("users").child(me.id!).child("bio")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            self.bioLabel.text = snapshot.value as! String
        })
        //add drink choice to profile view
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        
        displayProfile.text = "Name: \(me.name ?? "-1") \nAge: \(me.age) \nGender: \(me.gender ?? "-1")\nAge Range: \(me.ageLowerRange)-\(me.ageUpperRange)\nOrientation: \(me.orientation ?? "-1")\n"
            
        ref = Database.database().reference().child("users").child(me.id!)
        let storageRef = storage.reference()
        ref.observeSingleEvent(of: .value, with: {snapshot in
                
                if (snapshot.hasChild("selfie"))
                {
                    let filePath = "\(self.me.id ?? "god" )/selfie.jpg"
                    storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                        
                        let userPhoto = UIImage(data: data!)
                        self.profileImage.image = userPhoto
                    })
                }
            })
    }
    
    @IBAction func deactivate(_ sender: Any) {
        
        AppDelegate.sharedAppDelegate.coreDataStack.clearDatabase()
        //how to delete user from entire database
        /*locationManager.stopUpdatingLocation()
        UserDefaults.standard.set(false, forKey: "LOADED")
        transButton.isEnabled = true
        let alert = UIAlertController(title: "You do not have a profile", message: "Please create a profile to continue using the app", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "To Profile Creation", style: .default, handler: { action in
            self.transButton.sendActions(for: .touchUpInside)
            
        }))
        self.present(alert, animated: true, completion: nil)*/
        print("ran")
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "backToMap")
        {
            if let nextVC = segue.destination as? ViewController
            {
                nextVC.me = me
            }
        }
    }
}
