import SwiftUI

struct MarketResultView: View {
    let symbol: String
    let exchange: String?
    
    @State private var quote: QuoteResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var sharesOwned: Double = 0
    @State private var eurUsdRate: Double? = nil
    @State private var showTwelveDataView: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.95), .gray.opacity(0.25)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Loading...")
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
                        Divider().background(Color.white.opacity(0.2))
                        mySharesSection(for: quote)
                    }
                    .padding()
                }
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.headline)
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
        VStack(alignment: .leading, spacing: 4) {
            Text(quote.name ?? symbol)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            HStack(spacing: 12) {
                if quote.symbol == "AAPL" {
                    Text("")
                }
                Text("\(quote.symbol)")
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
    }
    
    private func priceSection(for quote: QuoteResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let close = quote.close, let number = Double(close) {
                Text("Current Price")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                HStack(alignment: .bottom, spacing: 20) {
                    Text("\(quote.currencySymbol)\(number.twoDecimalsString)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    if let eurUsdRate {
                        Text("\((number/eurUsdRate).twoDecimalsString) €")
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
                Text("Average Volume: \(quote.averageVolume ?? "-")")
                Text("Market Open: \(quote.isMarketOpen == true ? "✅ Open" : "❌ Closed")")
            }
            .foregroundColor(.white.opacity(0.8))
            .font(.subheadline)
        }
    }
    
    private func mySharesSection(for quote: QuoteResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Shares")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.bottom, 4)

            HStack {
                Text("Shares owned:")
                TextField("0", value: $sharesOwned, format: .number)
                #if os(iOS)
                    .keyboardType(.decimalPad)
                #endif
                    .frame(width: 100)
            }
            .foregroundColor(.white.opacity(0.9))

            if let closeStr = quote.close, let close = Double(closeStr) {
                let totalUSD = close * sharesOwned
                Text("Total value: \(quote.currencySymbol)\(totalUSD, format: .number.precision(.fractionLength(2)))")
                    .foregroundColor(.white)

                if let eurUsdRate = eurUsdRate {
                    let totalEUR = totalUSD / eurUsdRate
                    Text("Total value: \(totalEUR.currencyAmount)")
                        .foregroundColor(.white)
                    HStack {
                        Text("EUR/USD rate: \(eurUsdRate, format: .number.precision(.fractionLength(5)))")
                            .foregroundColor(.white.opacity(0.7))
                        Text("USD/EUR rate: \(1/eurUsdRate, format: .number.precision(.fractionLength(5)))")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                } else {
                    ProgressView("Fetching EUR/USD rate…")
                        .tint(.white)
                        .task {
                            guard let apiKey = AppIDs.twelveDataApiKey else { return }
                            do {
                                eurUsdRate = try await MarketRepository().fetchEURUSD(apiKey: apiKey)
                            } catch {
                                print("⚠️ EUR/USD fetch failed:", error)
                            }
                        }
                }
            }
        }
        .padding(.top)
    }
    
    private func fetchQuote() async {
        guard let apiKey = AppIDs.twelveDataApiKey else {
            showTwelveDataView = true
            return
        }
        do {
            let result = try await MarketRepository().fetchQuote(for: symbol, exchange: exchange, apiKey: apiKey)
            quote = result
            print(quote?.name ?? "No name")
        } catch {
            errorMessage = "Failed to load quote."
        }
        isLoading = false
    }
}

#Preview {
    MarketResultView(symbol: "AAPL", exchange: "NASDAQ")
}
