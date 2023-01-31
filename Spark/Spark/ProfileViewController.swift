//
//  ProfileViewController.swift
//  Spark
//
//  Created by Alex Kazaglis on 12/4/22.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
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
        
        genders = ["Female", "Male", "Nonbinary"]
        orientations = ["Female", "Male", "All"]
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        orientationPicker.delegate = self
        orientationPicker.dataSource = self
    }
    
        
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var ageLabel: UITextField!
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var orientationPicker: UIPickerView!
    @IBAction func finishButton(_ sender: Any) {
        
    }
    
    
    
    //make keyboard go away
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    //send data to next view controller on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toMatchScreen")
        {
            if let nextVC = segue.destination as? ViewController
            {
                nextVC.myName = nameLabel.text ?? "default"
                nextVC.myAge = Int(ageLabel.text ?? "-1") ?? -1
                nextVC.myGender = genders[genderPicker.selectedRow(inComponent: 0)]
                nextVC.myOrientation = orientations[orientationPicker.selectedRow(inComponent: 0)]
            }
        }
    }
    
}
