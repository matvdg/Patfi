import Foundation
import CoreLocation
import SwiftUI

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()
    
    private(set) var lastCoordinate: CLLocationCoordinate2D?
    private(set) var authorizationStatus: CLAuthorizationStatus

    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    /// Call once (e.g. onAppear or when toggling SaveLocation ON)
    func requestPermissionIfNeeded() {
        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    /// Best-effort single location request
    private var isAuthorizedForLocation: Bool {
#if os(iOS) || os(watchOS) || os(visionOS)
        return authorizationStatus == .authorizedWhenInUse
#else
        return authorizationStatus == .authorizedAlways
#endif
    }

    func requestOneShotLocation() {
        guard isAuthorizedForLocation else { return }
        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        lastCoordinate = locations.last?.coordinate
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Intentionally ignored: best-effort location
    }
}
