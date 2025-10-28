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
    @State private var eurUsdRate: Double? = nil
    @State private var showTwelveDataView: Bool = false
    
    @Binding var needsDismiss: Bool
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
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
                        Divider().background(Color.white.opacity(0.2))
                        mySharesSection(for: quote)
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
#if os(visionOS)
                    .buttonStyle(.borderedProminent)
#else
                    .buttonStyle(.glass)
#endif
                    
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
        VStack(alignment: .leading, spacing: 4) {
            Text(quote.name ?? symbol)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            HStack(spacing: 12) {
                if quote.symbol == "AAPL" {
                    Text("").foregroundStyle(.white)
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
            if let close = quote.close, let close = Double(close) {
                Text("Current Price")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                HStack(alignment: .bottom, spacing: 20) {
                    Text("\(quote.currencySymbol)\(close.twoDecimalsString)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    if let eurUsdRate {
                        Text("\((close/eurUsdRate).twoDecimalsString) €")
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
        VStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text("MyAssets")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.bottom, 4)
                
                HStack {
                    Text("QuantityOwned")
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
                if let closeStr = quote.close, let close = Double(closeStr) {
                    let totalUSD = close * quantity
                    Text("Total value: \(quote.currencySymbol)\(totalUSD, format: .number.precision(.fractionLength(2)))")
                        .foregroundColor(.white)
                    
                    if let eurUsdRate {
                        let totalEUR = totalUSD / eurUsdRate
                        Text("Total value: \(totalEUR.currencyAmount)")
                            .foregroundColor(.white)
                        if let account, let balance = account.currentBalance, let close = quote.close, let close = Double(close) {
                            let closeEuro = close/eurUsdRate
                            Text("Current account value: \(balance.currencyAmount)")
                                .foregroundColor(.white)
                            VStack(alignment: .center, spacing: 8) {
                                Button {
                                    quantity = balance / closeEuro
                                } label: {
                                    HStack(alignment: .center, spacing: 8) {
                                        Image(systemName: "equal.circle")
                                        Text("ComputeQuantity")
                                    }
                                }
#if os(visionOS)
                                .buttonStyle(.borderedProminent)
#else
                                .buttonStyle(.glass)
#endif
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        }
                        HStack {
                            Text("EuroUsdRate: \(eurUsdRate, format: .number.precision(.fractionLength(5)))")
                                .foregroundColor(.white.opacity(0.7))
                            Text("USD/EUR rate: \(1/eurUsdRate, format: .number.precision(.fractionLength(5)))")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else {
                        ProgressView("FetchingEuroUsdRate")
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
            if let account {
                SyncButton(account: account) {
                    guard let close = quote.close, let close = Double(close), let eurUsdRate, let exchange = quote.exchange else { return }
                    let totalUSD = close * quantity
                    let totalEUR = totalUSD / eurUsdRate
                    let newAsset = Asset(name: quote.name ?? quote.currencySymbol, quantity: quantity, symbol: quote.symbol, exchange: exchange, latestPrice: close, totalInAssetCurrency: totalUSD, totalInEuros: totalEUR, currencySymbol: quote.currencySymbol, account: account)
                    context.insert(newAsset)
                    account.asset = newAsset
                    BalanceRepository().add(amount: totalEUR, date: Date(), account: account, context: context)
                    do { try context.save() } catch { print("Save error:", error) }
                    needsDismiss = true
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .disabled(eurUsdRate == nil)
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
            let result = try await MarketRepository().fetchQuote(for: symbol, exchange: exchange, apiKey: apiKey)
            quote = result
            print(quote?.name ?? "No name")
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
