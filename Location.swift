//created by Will Roehr
import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var initialLocation: CLLocation?
    var isAwake = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            if initialLocation == nil {
                initialLocation = currentLocation
                startLocationChecking()
            }
        }
    }

    func startLocationChecking() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            guard let self = self else { return }
            if let initialLocation = self.initialLocation, let currentLocation = self.locationManager.location {
                let distance = initialLocation.distance(from: currentLocation)
                if distance > 0 {
                    self.isAwake = true
                } else {
                    self.isAwake = false
                    self.startLocationChecking()
                }
            } else {
                self.startLocationChecking()
            }
        }
    }
}

/* Here's what the code does:

    Import CoreLocation to access location services.
    Create a LocationManager class that inherits from NSObject and conforms to CLLocationManagerDelegate.
    Inside the class, create a CLLocationManager instance, an optional initialLocation, and a isAwake boolean.
    In the init method, set the delegate of locationManager, request location authorization, and start updating the location.
    Implement the locationManager(_, didUpdateLocations:) delegate method to capture the initial location and start checking the location every 10 seconds using the startLocationChecking method.
    Inside startLocationChecking, use DispatchQueue.main.asyncAfter to schedule location checking every 10 seconds. Compare the initial location with the current location, and update the isAwake boolean accordingly. If the user hasn't moved, continue checking the location.

Note: This code snippet assumes you have added the necessary privacy keys to your app's Info.plist file, such as NSLocationWhenInUseUsageDescription.
*/