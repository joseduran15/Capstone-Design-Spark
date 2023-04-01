//
//  AppDelegate.swift
//  Spark
//
//  Created by Alex Kazaglis on 10/29/22.
//

import UIKit
import FirebaseCore
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import FirebaseDatabase
import FirebaseDatabaseSwift
import SwiftUI
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    struct UserLocationSparkApp: App {
        var body: some Scene {
            WindowGroup {
                ContentView()
            }
        }
    }
    
    lazy var coreDataStack: CoreDataStack = .init(modelName: "Profile")

       static let sharedAppDelegate: AppDelegate = {
           guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
               fatalError("Unexpected app delegate type, did it change? \(String(describing: UIApplication.shared.delegate))")
           }
           return delegate
       }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        let loaded = UserDefaults.standard.bool(forKey: "LOADED")
        if(UserDefaults.standard.bool(forKey: "LOADED") == true)
        {
            UserDefaults.standard.set(false, forKey: "LOADED")
        }
        
        let stamp = UserDefaults.standard.object(forKey: "TIMESTAMP")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

