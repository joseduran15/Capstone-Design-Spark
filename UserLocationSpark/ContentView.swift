import MapKit
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    /* Variable region accounts for showing specific coordinate region within span, showcasing input coordinates */
    var body: some View {
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
            .onAppear() {
                viewModel.checkifLocationManagerIsEnabled()
            }
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
    
    func checkifLocationManagerIsEnabled() { /* Checks if user enabled location services */
        if CLLocationManager.locationServicesEnabled() { /* If location services are enabled, set location manager to CLLocationManager */
            locationManager = CLLocationManager()
            locationManager!.delegate = self /* Wrapping delegate for locationManager */
        } else {
            print("Tell user to turn on location services for Spark")
        }
    }
    
    private func checkLocationAuthorization() { /* Check if app has location permission and different cases to deal with */
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
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        /* Checks if location authorization was changed and sends alerts accordingly */
        checkLocationAuthorization()
    }
}
