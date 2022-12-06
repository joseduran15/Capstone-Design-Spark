//
//  ViewController.swift
//  DBSCAN Test
//
//  Created by Jose Duran on 12/4/22.
//

import UIKit
import MapKit
import CoreLocation
import Foundation
import CoreLocation



class ViewController: UIViewController, CLLocationManagerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create locations array...
        var locations: [CLLocation] = []

        // ...and fill it with CLLocation objects
        locations.append(CLLocation(latitude: 48.1623, longitude: 11.5798))
        locations.append(CLLocation(latitude: 48.1621, longitude: 11.5799))
        locations.append(CLLocation(latitude: 48.1603, longitude: 11.5763))
        locations.append(CLLocation(latitude: 48.1622, longitude: 11.5797))
       
        
        let dbscan = DBSCAN(locations)
        let (sequence, places) = dbscan.findCluster(eps: 75.0, minPts: 0)
        
        print(sequence)
        print(places)
       // print(locations)
        
        
        //var hey = DBSCAN(locations).printer(name: "manny")
       // self.scan.text = hey
    }
    
    @IBOutlet weak var scan: UILabel!
    
    
    
    
}
   
