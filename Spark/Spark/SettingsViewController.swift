//
//  SettingsViewController.swift
//  Spark
//
//  Created by Alex Kazaglis on 3/4/23.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController
{
    
    var me = User()
    
    @IBOutlet weak var displayProfile: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayProfile.text = "Your name: \(me.name) /nYour Age: \(me.age) /nYour Gender: \(me.gender)/n"
    }
}
