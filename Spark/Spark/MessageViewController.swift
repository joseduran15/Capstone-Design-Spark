//
//  MessageViewController.swift
//  Spark
//
//  Created by Jose Duran on 3/7/23.
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

class MessageViewController:  UIViewController, UITableViewDataSource,  UITableViewDelegate
{
    
    @IBOutlet var myTable: UITableView!
    
    
    var ref: DatabaseReference!
    var currDisplayed = "1000"
    var currDisplayedName = ""
    var me = User()
    //var data = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    var data = ["", "", "", "", ""]
    
    var data2 = ["", "", "", "", ""]
    
    //var matchIds = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTable.delegate = self
        myTable.dataSource = self
        
        myTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        ref = Database.database().reference()
        
        // Retrieve data from Firebase database
        ref.child("users").child(me.id!).child("matched").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get the data from the snapshot
            if(snapshot.exists())
            {
                var a: [String: Any] = [:]
                a = snapshot.value as! Dictionary<String, Any>
                a.values.forEach { name in
                    self.data[0] = name as? String ?? "error"
                    print(self.data)
                    print(name)
                    print("hello")
                }
                var b: [String: Any] = [:]
                b = snapshot.value as! Dictionary<String, Any>
                b.keys.forEach { name in
                    self.data2[0] = name as? String ?? "error"
                    print(self.data2)
                }
            }
                // Do something with the data
            }) { (error) in
                print(error.localizedDescription)
            }
        
        self.myTable.reloadData()
        
        }
    
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        print(self.data[indexPath.row])
        cell.textLabel?.text = self.data[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        print("You selected cell number: \(indexPath.row)")
        // Create an instance of the view controller you want to move to
               let destinationVC = ConversationViewController()
               // Pass any data to the destination view controller if needed
               //destinationVC.data = data[indexPath.row]
               // Push the destination view controller onto the navigation stack
                destinationVC.myString = self.data[indexPath.row]
                print(destinationVC.myString!)
                
               navigationController?.pushViewController(destinationVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showConvo", sender: self)
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        // Add the message to the data source
            self.myTable.reloadData()
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showConvo" {
            if let destinationVC = segue.destination as? ConversationViewController {
                destinationVC.myString = self.data[0]
                destinationVC.theID = self.data2[0]
                destinationVC.me = me
                print(data)
                print(data2)
                
                //FIX THIS FOR FINALLL DEMOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
            }
        }
    }
    /*func grabUser(completion: @escaping (_ message: String) -> Void)
     {
     ref = Database.database().reference().child("users").child(id of whichever user they clicked on).child("locData")
     // ref.observeSingleEvent(of: .value, with: {snapshot in}
     
     if (snapshot.exists())
     {}
     
     
     }
     }*/
    
}

