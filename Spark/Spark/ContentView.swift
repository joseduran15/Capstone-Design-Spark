import MapKit
import SwiftUI
import Firebase
import FirebaseAnalytics
import FirebaseAnalyticsSwift

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
/* Variable region accounts for showing specific coordinate region within span, showcasing input coordinates */
    @State var annotationItems: [User] = []
    
    func plotUsers() {
        for i in 0...10
        {
            var latData = 0.0
            var longData = 0.0
            var userName = ""
            
            var userAge = 0
            var ref: DatabaseReference!
            
            ref = Database.database().reference().child("users").child(String(i))
            ref.getData(completion:  { error, snapshot in
                guard error == nil else {
                    print("issue")
                    return;
                }
                var a: [String: Any] = [:]
                //turning datasnapshot returned from database into a dictionary
                a = snapshot?.value as! Dictionary<String, Any>
                //assigning values from the dictionary to variables so we don't have to type all the necessary error stuff every time
                latData = (a["locData"] as? [String:Any])?["lat"] as? Double ?? -1
                longData = (a["locData"] as? [String:Any])?["long"] as? Double ?? -1
                userName = (a["name"]) as! String
                userAge = Int((a["age"] as? [String:Any])?["age"] as? String ?? "-1") ?? -5
                print(latData)
                annotationItems.append(User(name:userName,age: userAge,latitude: latData,longitude: longData))
                        });
        }
    }
    
    
    var body: some View {
        let _ = self.plotUsers()
        Map(coordinateRegion: $viewModel.region,
            showsUserLocation: true,
            annotationItems: annotationItems) {place in
            MapMarker(coordinate: place.coordinate)
        }/*.onAppear() {
            viewModel.checkifLocationManagerIsEnabled()
        }*/
    }
}

struct ContentView_Previews: PreviewProvider { /* Shows map */
    static var previews: some View {
        ContentView()
    }
}

final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(
                                                   latitude: 38.898022, longitude: -77.050604),
                                                   span: MKCoordinateSpan(
                                                   latitudeDelta: 0.05, longitudeDelta: 0.05)) /* Can substitute region coordinates with longitude,latitude from firebase */
    
    var locationManager: CLLocationManager? /* Enables location services*/
    
    /*func checkifLocationManagerIsEnabled() { /* Checks if user enabled location services */
        if CLLocationManager.locationServicesEnabled() { /* If location services are enabled, set location manager to CLLocationManager */
            locationManager = CLLocationManager()
            locationManager!.delegate = self /* Wrapping delegate for locationManager */
        } else {
            print("Tell user to turn on location services for Spark")
        }
    }*/
    
    /*private func checkLocationAuthorization() { /* Check if app has location permission and different cases to deal with */
        guard let locationManager = locationManager else { return }
        switch locationManager.authorizationStatus {
            
        case .notDetermined: /* If notDetermined, need to ask for permission*/
            locationManager.requestWhenInUseAuthorization()
        case .restricted: /* Location services restricted, maybe from parental controls, etc */
            print("Location is restricted. Please check miscellaneous settings")
        case .denied: /* Spark denied location permission, must be changed in settings */
            print("Location permission was denied. Please update location permission in settings to use Spark")
        case .authorizedAlways, .authorizedWhenInUse: /* If permission authorized, update region */
            region = MKCoordinateRegion(center: locationManager.location!.coordinate,                                                                              span: MKCoordinateSpan(latitudeDelta: 0.05,longitudeDelta: 0.05))
        @unknown default: /* Default */
            break
        }
    }*/
    
    /*func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        /* Checks if location authorization was changed and sends alerts accordingly */
        checkLocationAuthorization()
    }*/
}
