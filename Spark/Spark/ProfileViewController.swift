//
//  ProfileViewController.swift
//  Spark
//
//  Created by Alex Kazaglis on 12/4/22.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import FirebaseCore
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import FirebaseDatabase
import FirebaseDatabaseSwift
import SwiftUI

class ProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
   
    var uID = ""
    var userCount = 1000
    var ref: DatabaseReference!
        
    @IBOutlet weak var ageLabel: UITextField!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var orientationPicker: UIPickerView!
    @IBAction func finishButton(_ sender: Any) {
        
    }
    
    @IBAction func clearCoreData(_ sender: Any) {
        AppDelegate.sharedAppDelegate.coreDataStack.clearDatabase()
        print("ran")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == genderPicker)
        {
            return genders[row] as String
        }
        else
        {
            return orientations[row] as String
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            
        }
    
    var genders: [String] = [String]()
    var orientations: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        genders = ["Female", "Male", "Nonbinary"]
        orientations = ["Female", "Male", "All"]
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        orientationPicker.delegate = self
        orientationPicker.dataSource = self
        
        
    }
    
    
    //make keyboard go away
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    func profileDataIntoDatabase()
    {
        //putting our user's data into a dictionary format for the database
        //first location data, we don't actually have the data yet so these are just placeholders to set up the database
        var locData: [String: Any] = [:]
        locData["lat"] = String(format : "%f", 0.0)
        locData["long"] =  String(format : "%f", 0.0)
        //then age data
        var ageData: [String: Any] = [:]
        ageData["age"] = ageLabel.text
        ageData["ageUpperRange"] = 35
        ageData["ageLowerRange"] = 25
        //then gender/orientation data
        var gendData: [String: Any] = [:]
        gendData["gender"] = genders[genderPicker.selectedRow(inComponent: 0)]
        gendData["orientation"] = orientations[orientationPicker.selectedRow(inComponent: 0)]
        var name = nameLabel.text
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
        uID = reference.key ?? "-1"
        //saving userID to persistant storage so when the app is open or closed it will save the profile
        let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
        let profile = NSEntityDescription.insertNewObject(forEntityName: "Profile", into: managedContext)
        profile.setValue(uID, forKey: "userID")
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
    
    func childObserver()
    {
        let query = ref.child("childCount")
        
        query.observe(.value, with: { snapshot in
            
            self.userCount = snapshot.value as! Int
            print("AAAAAAAAAAAAAAAAAAAA")
        })
    }
    
    //send data to next view controller on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toMapScreen")
        {
            if let nextVC = segue.destination as? ViewController
            {
                profileDataIntoDatabase()
                nextVC.me.name = nameLabel.text ?? "default"
                nextVC.me.age = Int(ageLabel.text ?? "-1") ?? -1
                nextVC.me.gender = genders[genderPicker.selectedRow(inComponent: 0)]
                nextVC.me.orientation = orientations[orientationPicker.selectedRow(inComponent: 0)]
                nextVC.me.id = uID
            }
        }
    }
    
}
