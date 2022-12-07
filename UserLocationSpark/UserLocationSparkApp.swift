//
//  UserLocationSparkApp.swift
//  UserLocationSpark
//
//  Created by Jay Samaraweera on 11/7/22.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct UserLocationSparkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
