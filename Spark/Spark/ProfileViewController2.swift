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

class ProfileViewController2: UIViewController, UITextViewDelegate
{
    
    var name = ""
    var age = -1
    var gender = ""
    var orientation = ""
    var id = ""
    var ref: DatabaseReference!
    
    @IBOutlet weak var minAge: UISlider!
    @IBOutlet weak var maxAge: UISlider!
    @IBOutlet weak var charactersUsed: UILabel!
    @IBOutlet weak var bio: UITextView!
    @IBOutlet weak var minAgeLabel: UILabel!
    @IBOutlet weak var maxAgeLabel: UILabel!
    
    var pressedButtons: [String] = []
    
    
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
            button.setTitleColor(.blue, for: .normal)
            button.setTitleColor(.red, for:. selected)
            button.addTarget(self, action: #selector(drinkButtons(_:)), for: .touchUpInside)
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
        
        bio.layer.borderColor = UIColor.lightGray.cgColor
        bio.layer.borderWidth = 1.0
        bio.layer.cornerRadius = 8
        
    }
    
    @IBAction func minSliderVal(_ sender: UISlider) {
        
        minAgeLabel.text = String(sender.value)
    }
    
    @IBAction func maxSliderVal(_ sender: UISlider) {
        maxAgeLabel.text = String(sender.value)
    }
    
    
    
    @objc func drinkButtons(_ sender: UIButton)
    {
        if(!sender.isSelected)
        {
            sender.isSelected = true
            pressedButtons.append(sender.currentTitle!)
            
        }
        else
        {
            sender.isSelected = false
            if let index = pressedButtons.firstIndex(of: sender.currentTitle!)
            {
                pressedButtons.remove(at: index)
            }
        }
        print(pressedButtons)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        charactersUsed.text = String(updatedText.count)
        return updatedText.count <= 75
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
        ref = Database.database().reference().child("users").child(id).child("bio")
        ref.setValue(bio.text)
        
        
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
