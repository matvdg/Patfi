import SwiftUI
import SwiftData

struct MarketSearchView: View {
    
    let account: Account?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var query: String = ""
    @State private var results: [QuoteResponse] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showTwelveDataView: Bool = false
    @State private var showFavs: Bool = true
    @State private var needsDismiss: Bool = false
    
    @State private var selectedFlag: String = String(localized: "All")
    @State private var selectedCurrency: String = String(localized: "All")
    @State private var selectedExchange: String = String(localized: "All")
    @State private var selectedInstrument: String = String(localized: "All")
    
    @FocusState private var isSearchFieldFocused: Bool
    @Query(sort: [SortDescriptor(\QuoteResponse.symbol, order: .forward)]) private var favs: [QuoteResponse]
    
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
    
    private let assetRepository = AssetRepository()
    private let marketRepository = MarketRepository()
    
    var body: some View {
        VStack {
            HStack {
                TextField("AAPL", text: $query)
                    .textFieldStyle(.roundedBorder)
#if !os(macOS)
                    .keyboardType(.asciiCapable)
                    .textInputAutocapitalization(.characters)
#endif
                    .autocorrectionDisabled(true)
                    .focused($isSearchFieldFocused)
                    .overlay(alignment: .trailing) {
                        if !query.isEmpty {
                            Button {
                                query = ""
                                results.removeAll()
                                showFavs = true
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onSubmit {
                        showFavs = false
                        Task { await performSearch() }
                    }
                    .onChange(of: query) {
                        query = query.uppercased()
                    }
                Button(action: {
                    showFavs = false
                    Task { await performSearch() }
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(query.isEmpty ? .gray.opacity(0.5) : .black)
                }
                .buttonStyle(.bordered)
                .disabled(query.isEmpty)
            }
            .padding()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isSearchFieldFocused = true
                }
            }
            
            if !showFavs {
#if os(macOS)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 20) {
                        Picker("Country", selection: $selectedFlag) {
                            ForEach(flags, id: \.self) { Text($0) }
                        }
                        Picker("Currency", selection: $selectedCurrency) {
                            ForEach(currencies, id: \.self) { Text($0) }
                        }
                        Picker("Exchange", selection: $selectedExchange) {
                            ForEach(exchanges, id: \.self) { Text($0) }
                        }
                        Picker("Type", selection: $selectedInstrument) {
                            ForEach(instruments, id: \.self) { Text($0) }
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal)
                }
#else
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
#endif
            }
            
            if isLoading {
                ProgressView()
                    .padding()
            }
            
            if let errorMessage = errorMessage {
                VStack(spacing: 20) {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding()
                    Button {
                        Task {
                            await performSearch()
                        }
                    } label: {
                        Label("Retry", systemImage: "arrow.clockwise").padding()
                    }
                    .modifier(ButtonStyleProminentModifier())
                }
            }
            
            Group {
                if results.isEmpty {
                    if showFavs {
                        // Display favorites
                        quoteList(for: favs)
                    } else {
                        // Display empty view
                        ContentUnavailableView("NoResult", systemImage: "exclamationmark.magnifyingglass")
                    }
                } else {
                    // Display results
                    quoteList(for: filteredResults)
                }
            }.frame(maxHeight: .infinity)
        }
        .navigationTitle("SymbolSearch")
        .navigationDestination(isPresented: $showTwelveDataView) {
            TwelveDataView()
        }
        .onChange(of: needsDismiss) {
            guard needsDismiss else { return }
            dismiss()
        }
    }
    
    func performSearch() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard let apiKey = AppIDs.twelveDataApiKey else {
            showTwelveDataView = true
            isLoading = false
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            var searchResults = try await marketRepository.searchQuotes(query: query, apiKey: apiKey)
            searchResults = searchResults.filter { $0.symbol == query }
            results = searchResults
        } catch {
            errorMessage = error.localizedDescription
            results = []
        }
        isLoading = false
    }
}

extension MarketSearchView {
    @ViewBuilder
    func quoteList(for results: [QuoteResponse]) -> some View {
        List(results) { quote in
            if let symbol = quote.symbol, let exchange = quote.exchange, let name = quote.instrumentName, let currency = quote.currency {
                QuoteRow(account: account, symbol: symbol, exchange: exchange, name: name, currency: currency, currencySymbol: quote.currencySymbol, instrumentType: quote.instrumentType, flag: quote.flag, country: quote.country, needsDismiss: $needsDismiss)
            }
        }
    }
}

#Preview {
    NavigationStack { MarketSearchView(account: nil) }.modelContainer(ModelContainer.shared)
}
