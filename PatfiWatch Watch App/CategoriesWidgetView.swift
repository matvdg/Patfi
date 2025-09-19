import SwiftUI

struct CategoriesWidgetView: View {
    
    var body: some View {
        VStack {
            ForEach(Array(BalanceReader.balancesByCategory.sorted { $0.key < $1.key }), id: \.key) { key, total in
                HStack {
                    let category = Category(rawValue: key) ?? .other
                    HStack(spacing: 8) {
                        Circle().fill(category.color).frame(width: 10, height: 10)
                        Text(category.localizedName).minimumScaleFactor(0.5)
                    }
                    Spacer()
                    Text(total.toString)
                        .minimumScaleFactor(0.5)
                }
            }
        }
    }
}

#Preview {
    CategoriesWidgetView()
}
