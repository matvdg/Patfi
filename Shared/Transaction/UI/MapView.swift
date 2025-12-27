import MapKit
import SwiftUI
import CoreLocation

struct MapView: View {
    
    let location: CLLocationCoordinate2D?
    let price: String
    let expenseCategory: Transaction.ExpenseCategory
    let position: MapCameraPosition

    init(location: CLLocationCoordinate2D?, price: String, expenseCategory: Transaction.ExpenseCategory) {
        self.location = location
        self.price = price
        self.expenseCategory = expenseCategory
        if let location {
            self.position = .camera(
                MapCamera(centerCoordinate: location, distance: 500)
            )
        } else {
            self.position = .automatic
        }
    }

    var body: some View {
        Map(position: .constant(position)) {
            if let location {
                Annotation(price, coordinate: location) {
                    Image(systemName: expenseCategory.iconName)
                        .font(.title)
                        .foregroundStyle(expenseCategory.color)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MapView(location:
                    CLLocationCoordinate2D(latitude: 42.83191, longitude: 1.03097), price: "$5.99", expenseCategory: .diningOut
        )}
}
