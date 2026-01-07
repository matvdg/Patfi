import MapKit
import SwiftUI
import CoreLocation

struct AddMapView: View {
    
    @Bindable var transaction: Transaction
    
    @Environment(\.dismiss) private var dismiss
    @Environment(LocationManager.self) private var locationManager
    
    @State private var position: MapCameraPosition = .automatic
    @State private var didSetInitialCamera = false
    @State private var isSatellite = false
    @State private var touchPoint: CGPoint? = nil
    
    var body: some View {
        MapReader { proxy in
            Map(position: $position) { }
                .mapStyle(isSatellite ? .hybrid : .standard)
                .simultaneousGesture(doubleTapGesture(using: proxy))
                .task {
                    // Apply immediately if we already have a coordinate.
                    guard !didSetInitialCamera, let coord = locationManager.lastCoordinate else { return }
                    position = .camera(MapCamera(centerCoordinate: coord, distance: 700))
                    didSetInitialCamera = true
                }
                .onChange(of: locationManager.lastCoordinate != nil) { _, hasLocation in
                    guard hasLocation,
                          !didSetInitialCamera,
                          let coord = locationManager.lastCoordinate
                    else { return }
                    
                    position = .camera(MapCamera(centerCoordinate: coord, distance: 700))
                    didSetInitialCamera = true
                }
        }
#if !os(watchOS)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    isSatellite.toggle()
                } label: {
                    Image(systemName: isSatellite ? "map" : "globe.europe.africa")
                }
            }
        }
#endif
        .navigationTitle("DoubleTapToAddLocation")
        .onAppear {
            locationManager.requestPermissionIfNeeded()
        }
        .task {
            locationManager.requestOneShotLocation()
        }
        .onChange(of: locationManager.authorizationStatus) { _, newValue in
            locationManager.requestOneShotLocation()
        }
    }
    
    private func doubleTapGesture(using proxy: MapProxy) -> some Gesture {
        TapGesture(count: 2)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
            .onEnded { value in
                guard case .second(_, let drag?) = value else { return }
                
                let point = drag.location
                touchPoint = point
                
                if let coordinate = proxy.convert(point, from: .local) {
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        transaction.lat = coordinate.latitude
                        transaction.lng = coordinate.longitude
                        
                        
                        dismiss()
                    }
                }
            }
    }
}

#Preview {
    let locationManager = LocationManager()
    
    return NavigationStack {
        AddMapView(transaction: Transaction(title: "Carrefour", transactionType: .expense, paymentMethod: .applePay, expenseCategory: .foodGroceries, date: Date(), amount: 20, account: nil, isInternalTransfer: false, lat: nil, lng: nil))
            .environment(locationManager)
    }
}
