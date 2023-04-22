import MapKit
import SwiftUI
import Firebase
import FirebaseAnalytics
import FirebaseAnalyticsSwift

/*
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
        
        for i in 0...99 {
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
*/



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
        
        var ref: DatabaseReference!
        ref = Database.database().reference().child("users")
        ref.getData(completion: { error, snapshot in
            guard error == nil else {
                print("Could not retrieve data")
                dispatchGroup.leave()
                return
            }
            
            var a: [String: [String:Any]] = [:]
            a = snapshot?.value as! [String: [String:Any]]
//            print(a)
            //get current user gender/orientation/drink preferences, then only extract users that match that in the for loop
            
            //gender is current user's gender, orientation is what you're looking for
            var userPref = ViewController.GlobalMe.meOrien
            var userGender = ViewController.GlobalMe.meGender
            
            
            for (_, value) in a {
                dispatchGroup.enter()
                let otherUserPref = (value["gendData"] as? [String:Any])?["orientation"] as? String ?? ""
                let otherUserGender = (value["gendData"] as? [String:Any])?["gender"] as? String ?? ""
//                print(otherUserPref)
//                print(otherUserGender)
                //if userPref == otherUserGender && userGender == otherUserPref {
                    let latData = (value["locData"] as? [String:Any])?["lat"] as? Double ?? -1
                    let longData = (value["locData"] as? [String:Any])?["long"] as? Double ?? -1
                    tempLocations.append(CLLocation(latitude: latData, longitude: longData))
                //}
                dispatchGroup.leave()
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
        })
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

