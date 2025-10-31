import SwiftUI
import SwiftData

struct QuoteFavButton: View {
    
    @Query(sort: [SortDescriptor(\QuoteResponse.symbol, order: .forward)]) private var favs: [QuoteResponse]
    
    @Environment(\.modelContext) private var context
    
    private var fav: QuoteResponse? {
        favs.first { symbol == $0.symbol && exchange == $0.exchange }
    }
    
    var symbol: String
    var exchange: String
    var name: String
    var currency: String
    
    var country: String? = nil
    var instrumentType: String? = nil
    
    
    var body: some View {
        FavButton(isFav: Binding(
            get: {
                return fav != nil
            },
            set: { newValue in
                let fav = favs.first { symbol == $0.symbol && exchange == $0.exchange }
                if newValue {
                    let newFav = QuoteResponse()
                    newFav.symbol = symbol
                    newFav.exchange = exchange
                    newFav.name = name
                    newFav.instrumentName = name
                    newFav.instrumentType = instrumentType
                    newFav.country = country
                    newFav.currency = currency
                    context.insert(newFav)
                } else {
                    if let fav {
                        context.delete(fav)
                    }
                }
                do {
                    try context.save()
                } catch {
                    print("Save error:", error)
                }
            }
        ))
    }
}

#Preview {
    QuoteFavButton(symbol: "AAPL", exchange: "NASDAQ", name: "Apple", currency: "USD", country: "USA", instrumentType: "Common Stock").modelContainer(ModelContainer.shared)
}
