import SwiftUI
import SwiftData

struct MarketSearchView: View {
    
    let account: Account?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
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
    
    var body: some View {
        VStack {
            HStack {
                TextField("AAPL", text: $query)
                    .textFieldStyle(.roundedBorder)
#if os(iOS)
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
                        }
                    }
                    .onSubmit {
                        showFavs = false
                        Task { await performSearch() }
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
#if os(visionOS)
                    .buttonStyle(.borderedProminent)
#else
                    .buttonStyle(.glass)
#endif
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
        .onChange(of: favs) {
            print("MarketSearchView favs: \(favs.count)")
            favs.forEach {
                print($0.name ?? "name nil", $0.instrumentName ?? "instrumentName nil", $0.instrumentType ?? "instrumentType nil", $0.symbol ?? "symbol nil", $0.exchange ?? "exchange nil")
            }
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

extension MarketSearchView {
    @ViewBuilder
    func quoteList(for results: [QuoteResponse]) -> some View {
        List(results) { quote in
            if let exchange = quote.exchange, let symbol = quote.symbol, let name = quote.instrumentName {
                HStack {
                    FavButton(isFav: Binding(
                        get: {
                            let fav = favs.first { quote.symbol == $0.symbol && quote.exchange == $0.exchange }
                            return fav != nil
                        },
                        set: { newValue in
                            let fav = favs.first { quote.symbol == $0.symbol && quote.exchange == $0.exchange }
                            if newValue {
                                let newFav = QuoteResponse()
                                newFav.symbol = quote.symbol
                                newFav.exchange = quote.exchange
                                newFav.instrumentName = quote.instrumentName
                                newFav.name = quote.instrumentName
                                newFav.instrumentType = quote.instrumentType
                                newFav.country = quote.country
                                newFav.currency = quote.currency
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
                                if let instrumentType = quote.instrumentType {
                                    Text(instrumentType)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Divider()
                            VStack(alignment: .center) {
                                if let flag = quote.flag {
                                    Text(flag)
                                        .font(.title2)
                                }
                                Text(quote.currencySymbol)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack { MarketSearchView(account: nil) }
}
