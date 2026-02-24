import SwiftUI
import SwiftData

struct MarketResultView: View {
    
    let symbol: String
    let exchange: String
    let account: Account?
    
    @State private var quote: QuoteResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var quantity: Double = 0
    @State private var euroDollarRate: Double? = nil
    @State private var showTwelveDataView: Bool = false
    
    @Binding var needsDismiss: Bool
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: [SortDescriptor(\QuoteResponse.symbol, order: .forward)]) private var favs: [QuoteResponse]
    
    private let assetRepository = AssetRepository()
    private let marketRepository = MarketRepository()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.95), .gray.opacity(0.25)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Loading")
                    .tint(.white)
                    .foregroundColor(.white)
                    .font(.headline)
            } else if let quote = quote {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection(for: quote)
                        Divider().background(Color.white.opacity(0.2))
                        priceSection(for: quote)
                        Divider().background(Color.white.opacity(0.2))
                        performanceSection(for: quote)
                        Divider().background(Color.white.opacity(0.2))
                        statsSection(for: quote)
                        myAssetsSection(for: quote)
                    }
                    .padding()
                }
            } else if let errorMessage = errorMessage {
                VStack(spacing: 20) {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding()
                    Button {
                        Task {
                            await fetchQuote()
                        }
                    } label: {
                        Label("Retry", systemImage: "arrow.clockwise").padding()
                    }
                    .modifier(ButtonStyleProminentModifier())
                    NavigationLink {
                        TwelveDataView()
                    } label: {
                        Label("EditApiKey", systemImage: "square.and.pencil").padding().foregroundStyle(Color.white)
                    }
                }
            }
        }
        .task {
            await fetchQuote()
        }
        .navigationTitle(symbol)
        .navigationDestination(isPresented: $showTwelveDataView) {
            TwelveDataView()
        }
    }
    
    private func headerSection(for quote: QuoteResponse) -> some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(quote.name ?? symbol)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                HStack(spacing: 12) {
                    if symbol == "AAPL" {
                        Text("").foregroundStyle(.white)
                    }
                    Text(symbol)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    if let exchange = quote.exchange {
                        Text(exchange)
                            .font(.subheadline)
                            .foregroundColor(.cyan)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.cyan.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    Text(quote.currencySymbol)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            Spacer()
            if let symbol = quote.symbol, let exchange = quote.exchange, let name = quote.name, let currency = quote.currency {
                QuoteFavButton(symbol: symbol, exchange: exchange, name: name, currency: currency)
            }
        }
    }
    
    private func priceSection(for quote: QuoteResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let close = quote.close, let close = Double(close) {
                Text("Current Price")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                HStack(alignment: .bottom, spacing: 20) {
                    Text("\(quote.currencySymbol)\(close.twoDecimalsString)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    if let euroDollarRate {
                        Text("\((close/euroDollarRate).twoDecimalsString) €")
                            .font(.headline)
                    }
                    
                }
                .foregroundColor(.green)
            }
            
            if let change = quote.change, let percent = quote.percentChange {
                let isPositive = (Double(change) ?? 0) >= 0
                HStack {
                    Image(systemName: isPositive ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                        .foregroundColor(isPositive ? .green : .red)
                    Text("\(isPositive ? "+" : "")\(change) (\(percent)%)")
                        .font(.headline)
                        .foregroundColor(isPositive ? .green : .red)
                }
            }
        }
    }
    
    private func performanceSection(for quote: QuoteResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Performance")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Open: \(quote.open ?? "-")")
                    Text("High: \(quote.high ?? "-")")
                    Text("Low: \(quote.low ?? "-")")
                    Text("Close: \(quote.close ?? "-")")
                    Text("Prev Close: \(quote.previousClose ?? "-")")
                }
                .foregroundColor(.white.opacity(0.8))
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    if let range = quote.fiftyTwoWeek?.range {
                        Text("52W Range:")
                            .foregroundColor(.white.opacity(0.6))
                        Text(range)
                            .foregroundColor(.white)
                    }
                }
            }
            .font(.subheadline)
        }
    }
    
    private func statsSection(for quote: QuoteResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Statistics")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 4) {
                Text("Volume: \(quote.volume ?? "-")")
                Text("AverageVolume: \(quote.averageVolume ?? "-")")
                Text("MarketOpen: \(quote.isMarketOpen == true ? "✅" : "❌")")
            }
            .foregroundColor(.white.opacity(0.8))
            .font(.subheadline)
        }
    }
    
    private func myAssetsSection(for quote: QuoteResponse) -> some View {
        Group {
            if let closeStr = quote.close, let close = Double(closeStr), let euroDollarRate, let account, let balance = account.currentBalance, let exchange = quote.exchange, let name = quote.name, let symbol = quote.symbol  {
                VStack(alignment: .center, spacing: 8) {
                    Divider().background(Color.white.opacity(0.2))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MyAssets")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.bottom, 4)
                        
                        HStack {
                            Text("Quantity")
                                .foregroundColor(.white.opacity(0.9))
                            TextField("0", value: $quantity, format: .number)
#if os(iOS)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
#endif
                                .frame(width: 100)
                                .textFieldStyle(.roundedBorder)
                        }
                        .foregroundColor(.primary)
                        let totalUSD = close * quantity
                        Text("Total value: \(quote.currencySymbol)\(totalUSD, format: .number.precision(.fractionLength(2)))")
                            .foregroundColor(.white)
                        let totalEUR = totalUSD / euroDollarRate
                        let closeEuro = close/euroDollarRate
                        let t = totalEUR.currencyAmount
                        let b = balance.currencyAmount
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Total value: \(t)")
                                Text("CurrentAccountValue: \(b)")
                            }
                            .foregroundColor(.white)
                            Button {
                                quantity = balance / closeEuro
                            } label: {
                                HStack {
                                    Text("}")
                                    Image(systemName: "equal.circle")
                                }
                                .font(.system(size: 40, design: .monospaced))
                            }
                            .disabled(t == b)
                            .opacity(t == b ? 0 : 1)
                        }
                        Text("EuroUsdRate: \(euroDollarRate, format: .number.precision(.fractionLength(5)))")
                            .foregroundColor(.white.opacity(0.7))
                        Button {
                            assetRepository.create(close: close, quantity: quantity, euroDollarRate: euroDollarRate, name: name, symbol: symbol, exchange: exchange, currencySymbol: quote.currencySymbol, account: account, context: context)
                            needsDismiss = true
                            dismiss()
                        } label: {
                            Label("SyncWith", systemImage: "arrow.trianglehead.2.clockwise.rotate.90").padding()
                        }
                        .modifier(ButtonStyleProminentModifier())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    }
                    .padding(.top)
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private func fetchQuote() async {
        guard let apiKey = AppIDs.twelveDataApiKey else {
            showTwelveDataView = true
            isLoading = false
            return
        }
        do {
            let result = try await marketRepository.fetchQuote(for: symbol, exchange: exchange, apiKey: apiKey)
            quote = result
            if quote?.currencySymbol == "$" {
                euroDollarRate = try await marketRepository.fetchEURUSD(apiKey: apiKey)
                if let account, let balance = account.currentBalance, let euroDollarRate, let close = quote?.close, let close = Double(close) {
                    let closeEuro = close/euroDollarRate
                    quantity = balance / closeEuro
                }
            }
        } catch {
            guard let error = error as? TwelveDataError else {
                return errorMessage = error.localizedDescription
            }
            switch error {
            case .requestFailed:
                errorMessage = String(localized: "ErrorApiNetwork")
            case .needUpgrade:
                errorMessage = String(localized: "ErrorApiUpgrade")
            default: errorMessage =
                error.localizedDescription
            }
        }
        isLoading = false
    }
    
}
