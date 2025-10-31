import SwiftUI
import SwiftData

struct QuoteRow: View {
    
    var account: Account? = nil
    
    var symbol: String
    var exchange: String
    var name: String
    var currency: String
    var currencySymbol: String
    
    var instrumentType: String? = nil
    var flag: String? = nil
    
    var country: String? = nil
    
    @Binding var needsDismiss: Bool
    
    private let marketRepository = MarketRepository()
    
    var body: some View {
        HStack {
            QuoteFavButton(symbol: symbol, exchange: exchange, name: name, currency: currency, country: country, instrumentType: instrumentType)
            NavigationLink(destination: MarketResultView(symbol: symbol, exchange: exchange, account: account, needsDismiss: $needsDismiss)) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(symbol)
                            .fontWeight(.bold)
                        Text(name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text(exchange)
                            .fontWeight(.bold)
                        if let instrumentType {
                            Text(instrumentType)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Divider()
                    VStack(alignment: .center) {
                        Text(currencySymbol)
                            .bold()
                            .font(.subheadline)
                        if let flag {
                            Text(flag)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            QuoteRow(account: nil, symbol: "AAPL", exchange: "NASDAQ", name: "Apple", currency: "USD", currencySymbol: "$", instrumentType: "Common Stock", flag: "🇺🇸", needsDismiss: .constant(false))
            QuoteRow(account: nil, symbol: "MSFT", exchange: "NASDAQ", name: "Microsoft", currency: "USD", currencySymbol: "$", instrumentType: nil, flag: nil, needsDismiss: .constant(false))
        }
    }.modelContainer(ModelContainer.shared)
}
