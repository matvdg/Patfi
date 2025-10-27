import SwiftUI

struct MarketResultView: View {
    let symbol: String
    let exchange: String?
    
    @State private var quote: QuoteResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.95), .gray.opacity(0.25)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Loading quote...")
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
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func headerSection(for quote: QuoteResponse) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(quote.name ?? symbol)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            HStack(spacing: 12) {
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
            if let close = quote.close {
                Text("Current Price")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                Text("\(close)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
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
    
    private func fetchQuote() async {
        do {
            let result = try await MarketRepository().fetchQuote(for: symbol, exchange: exchange)
            quote = result
        } catch {
            errorMessage = "Failed to load quote."
        }
        isLoading = false
    }
}

#Preview {
    MarketResultView(symbol: "AAPL", exchange: "NASDAQ")
}
