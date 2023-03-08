//
//  ProfileViewController2.swift
//  Spark
//
//  Created by Alex Kazaglis on 3/4/23.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import FirebaseDatabase
import FirebaseDatabaseSwift
import FirebaseStorage
import SwiftUI
import DoubleSlider

class ProfileViewController2: UIViewController, UITextFieldDelegate
{
    
    var name = ""
    var age = -1
    var gender = ""
    var orientation = ""
    var id = ""
    var ref: DatabaseReference!
    
    @IBOutlet weak var minAge: UISlider!
    @IBOutlet weak var maxAge: UISlider!
    @IBOutlet weak var bio: UITextField!
    @IBOutlet weak var charactersUsed: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        bio.delegate = self
        
        var things = ["vodka", "gin", "rum", "tequila", "amaretto", "whiskey", "bourbon","scotch", "baileys", "modelo", "corona", "IPA", "cranberry", "lemon", "lime", "orange", "grenadine", "soda", "coke", "pepsi", "sour", "on the rocks", "neat", "shot"]
        
        var drinkOptions: [UIButton] = []
        var theX = 0
        var theY = 475
        for x in things
        {
            let button:UIButton = UIButton(frame: CGRect(x: theX, y: theY, width: 100, height: 50))
            button.setTitle(x, for: .normal)
            button.setTitleColor(.red, for: .normal)
            self.view.addSubview(button)
            
            if(theX + 50 > Int(self.view.frame.width))
            {
                theX = 0
                theY += 40
            }
            else
            {
                theX += 100
            }
        }
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        charactersUsed.text = "\(textField.text?.count)"
        let maxLength = 75
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)

        return newString.count <= maxLength
    }
    
    //make keyboard go away
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    func moreDataIntoDatabase()
    {
        ref = ref.child("users").child(id).child("ageData")
        var ageLowerRange: [String: Any] = [:]
        ageLowerRange["ageLowerRange"] = minAge.value
        ref.updateChildValues(ageLowerRange)
        var ageUpperRange: [String: Any] = [:]
        ageUpperRange["ageUpperRange"] = maxAge.value
        ref.updateChildValues(ageUpperRange)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "mapScreenSegue")
        {
            if let nextVC = segue.destination as? ViewController
            {
                moreDataIntoDatabase()
                nextVC.me.name = name
                nextVC.me.age = age
                nextVC.me.gender = gender
                nextVC.me.orientation = orientation
                nextVC.me.id = id
            }
        }
    }
    
    
}
