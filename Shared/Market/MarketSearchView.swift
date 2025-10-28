import SwiftUI

struct MarketSearchView: View {
    @State private var query: String = ""
    @State private var results: [QuoteResponse] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showTwelveDataView: Bool = false

    @State private var selectedFlag: String = String(localized: "All")
    @State private var selectedCurrency: String = String(localized: "All")
    @State private var selectedExchange: String = String(localized: "All")
    @State private var selectedInstrument: String = String(localized: "All")

    @FocusState private var isSearchFieldFocused: Bool

    var flags: [String] { [String(localized: "All")] + Set(results.compactMap { $0.flag }).sorted() }
    var currencies: [String] { [String(localized: "All")] + Set(results.compactMap { $0.currencySymbol }).sorted() }
    var exchanges: [String] { [String(localized: "All")] + Set(results.compactMap { $0.exchange }).sorted() }
    var instruments: [String] { [String(localized: "All")] + Set(results.compactMap { $0.instrumentType }).sorted() }

    var filteredResults: [QuoteResponse] {
        results.filter {
            (selectedFlag == String(localized: "All") || $0.flag == selectedFlag) &&
            (selectedCurrency == String(localized: "All") || $0.currencySymbol == selectedCurrency) &&
            (selectedExchange == String(localized: "All") || $0.exchange == selectedExchange) &&
            (selectedInstrument == String(localized: "All") || $0.instrumentType == selectedInstrument)
        }
    }

    var body: some View {
        VStack {
            HStack {
                TextField("SYMBOL e.g. AAPL", text: $query)
                    .textFieldStyle(.roundedBorder)
                #if os(iOS)
                    .keyboardType(.asciiCapable)
                    .textInputAutocapitalization(.characters)
                #endif
                    .autocorrectionDisabled(true)
                    .focused($isSearchFieldFocused)
                    .onSubmit {
                        Task { await performSearch() }
                    }
                Button(action: {
                    Task { await performSearch() }
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            .padding()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isSearchFieldFocused = true
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    HStack {
                        Text("Country")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Picker("Country", selection: $selectedFlag) {
                            ForEach(flags, id: \.self) { Text($0) }
                        }
                    }
                    HStack {
                        Text("Currency")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Picker("Currency", selection: $selectedCurrency) {
                            ForEach(currencies, id: \.self) { Text($0) }
                        }
                    }
                    HStack {
                        Text("Exchange")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Picker("Exchange", selection: $selectedExchange) {
                            ForEach(exchanges, id: \.self) { Text($0) }
                        }
                    }
                    HStack {
                        Text("Type")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Picker("Type", selection: $selectedInstrument) {
                            ForEach(instruments, id: \.self) { Text($0) }
                        }
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
            }

            if isLoading {
                ProgressView()
                    .padding()
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            List(filteredResults) { quote in
                NavigationLink(destination: MarketResultView(symbol: quote.symbol, exchange: quote.exchange)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(quote.symbol)
                                .fontWeight(.bold)
                            Text(quote.instrumentName ?? quote.name ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(quote.exchange ?? "")
                                .fontWeight(.bold)
                            Text(quote.instrumentType ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Divider()
                        VStack(alignment: .center) {
                            Text(quote.flag)
                                .font(.title2)
                            Text(quote.currencySymbol)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Market search")
        .navigationDestination(isPresented: $showTwelveDataView) {
            TwelveDataView()
        }
    }

    func performSearch() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard let apiKey = AppIDs.twelveDataApiKey else {
            showTwelveDataView = true
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            var searchResults = try await MarketRepository().searchQuotes(query: query, apiKey: apiKey)
            searchResults = searchResults.filter { $0.symbol == query }
            results = searchResults
        } catch {
            errorMessage = error.localizedDescription
            results = []
        }
        isLoading = false
    }
}

#Preview {
    MarketSearchView()
}
