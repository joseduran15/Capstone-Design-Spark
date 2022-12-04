//
//  ProfileViewController.swift
//  Spark
//
//  Created by Alex Kazaglis on 12/4/22.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
            
    }
        
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var attractionPicker: UIPickerView!
    @IBAction func finishButton(_ sender: Any) {
    }
    
    
}
