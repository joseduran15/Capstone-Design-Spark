//
//  ConversationViewController.swift
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

struct ChatMessage {
    let text: String
    var isIncoming: Bool
}

class ConversationViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource,  UITableViewDelegate {

    var data = ["From Spark: Hey! You can now chat with your match<3", "", "", "", "", "", "", "", "", "", ""]
    
    var i = 0
    
    private var timer: Timer?
    var ref: DatabaseReference!
    var currDisplayed = ""
    var currDisplayedName = ""
    var me = User()
    var conversations: [String] = []
    
    var myString: String?
    var theID: String?
    //-NPxxBPHDdzgCQkhdbTD

    
    @IBOutlet var nameOfPerson: UILabel!
    @IBOutlet weak var textTable: UITableView!
    @IBOutlet var inputField: UITextField!
    
        
    var messages = ([String]).self
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            timer?.invalidate()
            
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true){_ in
                let _ = self.textTable.reloadData()
            }
            
            
            nameOfPerson.text = myString
            
            textTable.delegate = self
            textTable.dataSource = self
            
           // textTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            textTable.register(ChatMessageCell.self, forCellReuseIdentifier: "cell")
            textTable.separatorStyle = .none
            textTable.backgroundColor = UIColor(white: 0.95, alpha: 1)
            
            //CREATE CONVO DICTIONARY
        
            //print(theID!)
            var ref1 = Database.database().reference().child("users").child(self.me.id!).child("conversations")
            ref1.observeSingleEvent(of: .value, with: {snapshot in
                if(!snapshot.exists())
                {
                    print("id \(self.me.id)")
                    var conversations: [String: Any] = [:]
                    var convo1: [String : Any] = [:]
                    for i in 0...8
                    {
                        convo1[String(i)] = self.data[i]
                    }
                    
                    conversations[self.theID!] = convo1
                    ref1.updateChildValues(conversations)
                }
                else if(snapshot.hasChild(self.theID!))
                {
                    var ref2 = Database.database().reference().child("users").child(self.me.id!).child("conversations").child(self.theID!)
                    ref2.observeSingleEvent(of: .value, with: {snapshot in
                        var a: [String] = []
                        a = snapshot.value as! [String]
                        var count = 0
                        a.forEach { message in
                            self.data[count] = message as! String
                            count += 1
                        }
                       /* var count = 0
                        var a: [String: Any] = [:]
                        a = snapshot.value as! Dictionary<String, Any>
                        a.values.forEach { message in
                            self.data[count] = message as! String
                            count+=1
                        }*/
                    })
                }
                    
                
            })
            
            var ref2 = Database.database().reference().child("users").child(theID!).child("conversations")
            ref2.observeSingleEvent(of: .value, with: {snapshot in
                if(!snapshot.exists())
                {
                    
                    var conversations: [String: Any] = [:]
                    var convo1: [String : Any] = [:]
                    for i in 0...8
                    {
                        convo1[String(i)] = self.data[i]
                    }
                    
                    conversations[self.me.id!] = convo1
                    ref2.updateChildValues(conversations)
                }
                else if(snapshot.hasChild(self.me.id!))
                {
                    var ref3 = Database.database().reference().child("users").child(self.theID!).child("conversations").child(self.me.id!)
                    ref3.observeSingleEvent(of: .value, with: {snapshot in
                        var a: [String] = []
                        a = snapshot.value as! [String]
                        var count = 0
                        a.forEach { message in
                            self.data[count] = message
                            count += 1
                        }
                    })
                }
                    
                
            })
            
            // Add tap gesture recognizer to the view to dismiss keyboard when tapped
               let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               view.addGestureRecognizer(tapGesture)
               
               // Set the view controller as the text field's delegate
               inputField.delegate = self
            
        }
    
        @IBAction func sendButtonPressed(_ sender: Any) {
            // Add the message to the data source
       
            var firstIndex = 0
            for i in data{
                if (i == "")
                {
                    break
                }
                firstIndex += 1
            }
            
            var newString = "\(me.id ?? "error") \(inputField.text ?? "error" )"
                //update the dictionary
            
            var ref1 = Database.database().reference().child("users").child(self.me.id!).child("conversations").child(self.theID!).child(String(firstIndex))
            ref1.setValue(newString)
            
            
            var ref2 = Database.database().reference().child("users").child(self.theID!).child("conversations").child(self.me.id!).child(String(firstIndex))
            ref2.setValue(newString)
                //upload inputField.text to created dictionary
            inputField.text = ""
                self.textTable.reloadData()
            
        }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard when the user taps "Return"
        print(inputField.text)
        //self.data[1] = inputField.text!
       /* for i in 0...8
        {
            if(data[i] == "")
            {
                self.data[i] = inputField.text!
                break
            }
        }*/
        return true
    }
    
    @objc func dismissKeyboard() {
        inputField.resignFirstResponder() // Dismiss the keyboard when the user taps outside of the text field
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatMessageCell
        print(self.data[indexPath.row])
       
       if let index1 = self.data[indexPath.row].firstIndex(of: " ")
       {
           var index = String.Index(index1, within:self.data[indexPath.row])!
           cell.messageLabel.text = self.data[indexPath.row].substring(from: index)
           if(self.data[indexPath.row].contains(me.id!))
           {
               
               var chatMessage = ChatMessage(text: self.data[indexPath.row].substring(from: index), isIncoming: false)
               cell.chatMessage = chatMessage
           }
           else
           {
               //cell.messageLabel.textAlignment = .left
               
               var chatMessage = ChatMessage(text: self.data[indexPath.row].substring(from: index), isIncoming: true)
               cell.chatMessage = chatMessage
           }
       }
       else
       {
           
           if(self.data[indexPath.row].contains(me.id!))
           {
               var chatMessage = ChatMessage(text: self.data[indexPath.row], isIncoming: false)
               cell.chatMessage = chatMessage
               //cell.bubbleBackgroundView.backgroundColor =  .darkGray
           }
           else
           {
               //cell.messageLabel.textAlignment = .left
               
               var chatMessage = ChatMessage(text: self.data[indexPath.row], isIncoming: true)
               cell.chatMessage = chatMessage
           }
       }
       //var index = String.Index(index1, within:self.data[indexPath.row].utf16)
      
       
        //get uid from data[indexPath.row] through splitting the string
        //if my uid aligh right, else align left
        return cell
    }
}
