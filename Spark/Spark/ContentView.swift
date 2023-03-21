import MapKit
import SwiftUI
import Firebase
import FirebaseAnalytics
import FirebaseAnalyticsSwift

//struct ContentView: View {
//    @StateObject private var viewModel = ContentViewModel()
//
///* Variable region accounts for showing specific coordinate region within span, showcasing input coordinates */
//    @State var annotationItems: [User] = []
//    @State var locations: [CLLocation] = []
//    @State var circleOverlays: [MKCircle] = []
//
//    func plotUsers() {
//        for i in 0...20
//        {
//            var latData = 0.0
//            var longData = 0.0
//            var userName = ""
//            var userAge = 0
//            var ref: DatabaseReference!
//
//            ref = Database.database().reference().child("users").child(String(i))
//            ref.getData(completion:  { error, snapshot in
//                guard error == nil else {
//                    print("issue")
//                    return;
//                }
//                var a: [String: Any] = [:]
//                //turning datasnapshot returned from database into a dictionary
//                a = snapshot?.value as! Dictionary<String, Any>
//                //assigning values from the dictionary to variables so we don't have to type all the necessary error stuff every time
//                latData = (a["locData"] as? [String:Any])?["lat"] as? Double ?? -1
//                longData = (a["locData"] as? [String:Any])?["long"] as? Double ?? -1
//                userName = (a["name"]) as! String
//                userAge = Int((a["age"] as? [String:Any])?["age"] as? String ?? "-1") ?? -5
//                annotationItems.append(User(name:userName,age: userAge,latitude: latData,longitude: longData))
//                self.locations.append(CLLocation(latitude: latData, longitude: longData))
//            });
//        }
//        print("@@@@@@@@@@@@@@@@@@@@@@@Locations:@@@@@@@@@@@@@@@@@@@@@@@@",locations.count)
//
//        let dbscan = DBSCAN(self.locations)
//        let (sequence, places) = dbscan.findCluster(eps: 1000.0, minPts: 2)
//        print("@@@@@@@@@@@@@@@@@@@@@@@Places:@@@@@@@@@@@@@@@@@@@@@@@@",places)
//
//        for place in places {
//            print("Cluster:", place.members.count)
//            let circle = MKCircle(center: place.location.coordinate, radius: 1000)
//            self.circleOverlays.append(circle)
//        }
//        self.viewModel.mapView.addOverlays(circleOverlays)
//        print("@@@@@@@@@@@@@@@@@@@@@@@Circles:@@@@@@@@@@@@@@@@@@@@@@@@",circleOverlays)
//
//    }
//
//    private var timer: Timer?
//
//    var body: some View {
//        Map(coordinateRegion: $viewModel.region,
//            showsUserLocation: true)
//        .onAppear() {
////            viewModel.mapView.delegate = viewModel
//            let _ = self.plotUsers()
//            timer?.invalidate()
//            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
//                let _ = self.plotUsers()
//                self.locations.removeAll()
//                self.viewModel.mapView.removeOverlays(circleOverlays)
//                self.circleOverlays.removeAll()
//            }
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider { /* Shows map */
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate, MKMapViewDelegate {
//    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(
//                                                   latitude: 38.898022, longitude: -77.050604),
//                                                   span: MKCoordinateSpan(
//                                                   latitudeDelta: 0.05, longitudeDelta: 0.05)) /* Can substitute region coordinates with longitude,latitude from firebase */
//
//    var locationManager: CLLocationManager? /* Enables location services*/
//    var mapView: MKMapView
//
//    override init() {
//        mapView = MKMapView()
//        super.init()
//        mapView.delegate = self
//    }
//
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if let circleOverlay = overlay as? MKCircle {
//            let circleRenderer = MKCircleRenderer(circle: circleOverlay)
//            circleRenderer.fillColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.3)
//            circleRenderer.strokeColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.7)
//            circleRenderer.lineWidth = 2.0
//            return circleRenderer
//        }
//        return MKOverlayRenderer()
//    }

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
//}




//import SwiftUI
//struct MapView: UIViewRepresentable {
//
//  var locationManager = CLLocationManager()
//  func setupManager() {
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    locationManager.requestWhenInUseAuthorization()
//    locationManager.requestAlwaysAuthorization()
//  }
//
//  func makeUIView(context: Context) -> MKMapView {
//    setupManager()
//    let mapView = MKMapView(frame: UIScreen.main.bounds)
//    mapView.showsUserLocation = true
//    mapView.userTrackingMode = .follow
//    return mapView
//  }
//
//  func updateUIView(_ uiView: MKMapView, context: Context) {
//  }
//
//    private func addOverlays(mapView: MKMapView) {
//        let coordinates = [
//            CLLocationCoordinate2D(latitude: 38.903404, longitude: -77.036574),
//            CLLocationCoordinate2D(latitude: 38.907192, longitude: -77.036871),
//            CLLocationCoordinate2D(latitude: 38.906570, longitude: -77.039665),
//            CLLocationCoordinate2D(latitude: 38.901417, longitude: -77.037718),
//            CLLocationCoordinate2D(latitude: 38.900038, longitude: -77.033737)
//        ]
//        for coordinate in coordinates {
//            let circle = MKCircle(center: coordinate, radius: 200)
//            circle.title = "Overlay"
//            circle.subtitle = "Radius: 200m"
//            mapView.addOverlay(circle)
//        }
//    }
//}
//
//class Coordinator: NSObject, MKMapViewDelegate {
//    var parent: MapView
//
//    init(_ parent: MapView) {
//        self.parent = parent
//        super.init()
//    }
//
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if let circleOverlay = overlay as? MKCircle {
//            let circleRenderer = MKCircleRenderer(circle: circleOverlay)
//            circleRenderer.fillColor = UIColor.red.withAlphaComponent(0.1)
//            circleRenderer.strokeColor = .red
//            circleRenderer.lineWidth = 1
//            return circleRenderer
//        }
//        return MKOverlayRenderer()
//    }
//}
//
//func makeCoordinator() -> Coordinator {
//    Coordinator(self)
//}
//
//struct ContentView: View {
//  var body: some View {
//    MapView()
//  }
//}
//
//struct ContentView_Previews: PreviewProvider {
//  static var previews: some View {
//    ContentView()
//  }
//}

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {

    @StateObject private var locationManager = LocationManager()
    @State var locations: [CLLocation] = []
    private var timer: Timer?
    let startCount = 0
    

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if let userLocation = locationManager.lastLocation {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
        
        if startCount == 0 {
            let _ = addHotSpots(to: mapView)
        }
        
        timer?.invalidate()
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            let _ = addHotSpots(to: mapView)
            locations.removeAll()
            for overlay in mapView.overlays {
                mapView.removeOverlay(overlay)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {

        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
            super.init()
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.fillColor = UIColor.red.withAlphaComponent(0.2)
                renderer.strokeColor = .red
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
    
    private func addHotSpots(to mapView: MKMapView) {
        var tempLocations: [CLLocation] = []
        let dispatchGroup = DispatchGroup()
        
        for i in 0...100 {
            dispatchGroup.enter()
            var ref: DatabaseReference!
            ref = Database.database().reference().child("users").child(String(i))
            ref.getData(completion: { error, snapshot in
                guard error == nil else {
                    print("issue")
                    dispatchGroup.leave()
                    return
                }
                var a: [String: Any] = [:]
                //turning datasnapshot returned from database into a dictionary
                a = snapshot?.value as! Dictionary<String, Any>
                //assigning values from the dictionary to variables so we don't have to type all the necessary error stuff every time
                let latData = (a["locData"] as? [String:Any])?["lat"] as? Double ?? -1
                let longData = (a["locData"] as? [String:Any])?["long"] as? Double ?? -1
                tempLocations.append(CLLocation(latitude: latData, longitude: longData))
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            self.locations = tempLocations
            let dbscan = DBSCAN(tempLocations)
            let (_, places) = dbscan.findCluster(eps: 1000.0, minPts: 2)

            for place in places {
                let radius = 75 * place.members.count
                let circle = MKCircle(center: place.location.coordinate, radius: CLLocationDistance(radius))
                mapView.addOverlay(circle)
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            self.lastLocation = lastLocation
        }
    }
}

struct ContentView: View {
    var body: some View {
        MapView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


