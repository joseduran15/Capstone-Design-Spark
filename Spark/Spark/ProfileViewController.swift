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
import FirebaseStorage
import SwiftUI
import AVFoundation

class ProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
   
    var uID = ""
    var userCount = 1000
    var ref: DatabaseReference!
    let storage = Storage.storage()
        
    @IBOutlet weak var ageLabel: UITextField!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var orientationPicker: UIPickerView!
    @IBAction func finishButton(_ sender: Any) {
        
    }
    
    @IBOutlet weak var imageDisplay: UIImageView!
    
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
        
        //download childcount from database and assign it to usercount
        var reference = Database.database().reference()
        reference.getData(completion:  {  error, snapshot in
            guard error == nil else {
                print("issue")
                return;
            }
            
            var a: [String: Any] = [:]
            //turning datasnapshot returned from database into a dictionary
            a = snapshot?.value as! Dictionary<String, Any>
            
            self.userCount = a["childCount"] as! Int
            print(self.userCount)
            
        });
        
        
    }
    
    @IBAction func selfie(_ sender: Any) {
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        DispatchQueue.main.async {
            
            switch cameraAuthorizationStatus {
            case .notDetermined: self.requestCameraPermission()
            case .authorized: self.presentCamera()
            case .restricted, .denied: self.alertCameraAccessNeeded()
            }
        }
    }
    
    func requestCameraPermission() {
       AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
           guard accessGranted == true else { return }
           self.presentCamera()
       })
    }
    
    func presentCamera() {
        let photoPicker = UIImagePickerController()
        photoPicker.sourceType = .camera
        photoPicker.delegate = self
    
        self.present(photoPicker, animated: true, completion: nil)
    }
    
    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
     
         let alert = UIAlertController(
             title: "Need Camera Access",
             message: "Camera access is required to make full use of this app.",
             preferredStyle: UIAlertController.Style.alert
         )
     
       alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
    
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageDisplay.image = image
        }
        print("hi")
        dismiss(animated: true, completion: nil)
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
        //selfie data
        let storageRef = storage.reference()
        let selfieRef = storageRef.child("\(childautoID ?? "yeet")/selfie.jpg")
        var data = NSData()
        data = imageDisplay.image!.jpegData(compressionQuality: 0.8)! as NSData
        let uploadTask = selfieRef.putData(data as Data, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            return
          }
          let size = metadata.size
          // You can also access to download URL after upload.
          selfieRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
              // Uh-oh, an error occurred!
              return
            }
              self.ref.child("users").child(childautoID!).updateChildValues(["selfie": downloadURL.absoluteString])
          }
        }
        
        
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
        if(segue.identifier == "toNextProfile")
        {
            if let nextVC = segue.destination as? ProfileViewController2
            {
                profileDataIntoDatabase()
                nextVC.name = nameLabel.text ?? "default"
                nextVC.age = Int(ageLabel.text ?? "-1") ?? -1
                nextVC.gender = genders[genderPicker.selectedRow(inComponent: 0)]
                nextVC.orientation = orientations[orientationPicker.selectedRow(inComponent: 0)]
                nextVC.id = uID
            }
        }
    }
    
}
