//
//  ProfileViewController.swift
//  Spark
//
//  Created by Alex Kazaglis on 12/4/22.
//

import Foundation
import UIKit
import CoreData

class ProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
   
    
        
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
        
        print("fpor teh love of god")
        
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
    
    //send data to next view controller on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toMapScreen")
        {
            if let nextVC = segue.destination as? ViewController
            {
                nextVC.me.name = nameLabel.text ?? "default"
                nextVC.me.age = Int(ageLabel.text ?? "-1") ?? -1
                nextVC.me.gender = genders[genderPicker.selectedRow(inComponent: 0)]
                nextVC.me.orientation = orientations[orientationPicker.selectedRow(inComponent: 0)]
            }
        }
    }
    
}
