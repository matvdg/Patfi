import SwiftUI

struct WatchMainView: View {
    var body: some View {
        TabView {
            TotalWidgetView()
            CategoriesWidgetView()
            PieChartWidgetView()
            BanksWidgetView()
        }
        .tabViewStyle(.verticalPage)
    }
}

#Preview {
    WatchMainView()
}
