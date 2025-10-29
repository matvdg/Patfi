import Foundation
import SwiftData

enum TwelveDataError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case needUpgrade
}

class MarketRepository {
    
    private let baseURL = URL(string: "https://api.twelvedata.com")!
    
    /// Fetches the latest quote for a given symbol from Twelve Data API.
    /// - Parameter symbol: The ticker symbol to fetch.
    /// - Parameter exchange: The optional exchange code.
    /// - Returns: QuoteResponse with symbol, name, price, and currency.
    func fetchQuote(for symbol: String, exchange: String, apiKey: String) async throws -> QuoteResponse {
                
        // Construct the URL for the quote endpoint
        var components = URLComponents(url: baseURL.appendingPathComponent("quote"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "exchange", value: exchange),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        
        guard let url = components?.url else {
            throw TwelveDataError.invalidURL
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw TwelveDataError.requestFailed
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw TwelveDataError.requestFailed
        }
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🧾 JSON Response:\n\(jsonString)")
        }
        let json = String(decoding: data, as: UTF8.self)
        if json.contains("404") {
            throw TwelveDataError.needUpgrade
        }
        do {
            let decoder = JSONDecoder()
            let quote = try decoder.decode(QuoteResponse.self, from: data)
            return quote
        } catch {
            throw TwelveDataError.decodingFailed
        }
    }
    
    /// Searches for quotes matching the query from Twelve Data API.
    /// - Parameter query: The search query (symbol or name).
    /// - Returns: An array of QuoteResponse matching the query.
    func searchQuotes(query: String, apiKey: String) async throws -> [QuoteResponse] {
        var components = URLComponents(url: baseURL.appendingPathComponent("symbol_search"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: query),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        
        guard let url = components?.url else {
            throw TwelveDataError.invalidURL
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw TwelveDataError.requestFailed
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw TwelveDataError.requestFailed
        }
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🧾 JSON Response:\n\(jsonString)")
        }
        do {
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(SymbolSearchResponse.self, from: data)
            return searchResponse.data
        } catch {
            throw TwelveDataError.decodingFailed
        }
    }
    
    /// Fetches the latest EUR/USD exchange rate (last close value) from Twelve Data API.
    /// - Returns: The most recent close value as Double.
    func fetchEURUSD(apiKey: String) async throws -> Double {
        var components = URLComponents(url: baseURL.appendingPathComponent("time_series"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: "EUR/USD"),
            URLQueryItem(name: "interval", value: "1min"),
            URLQueryItem(name: "outputsize", value: "1"),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        
        guard let url = components?.url else {
            throw TwelveDataError.invalidURL
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw TwelveDataError.requestFailed
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw TwelveDataError.requestFailed
        }
        
        struct TimeSeriesResponse: Codable {
            struct Value: Codable { let close: String }
            let values: [Value]
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(TimeSeriesResponse.self, from: data)
            guard let closeValue = result.values.first?.close, let close = Double(closeValue) else {
                throw TwelveDataError.decodingFailed
            }
            return close
        } catch {
            throw TwelveDataError.decodingFailed
        }
    }
    
    /// Validates if a Twelve Data API key is valid by performing a lightweight test request.
    /// - Parameter apiKey: The API key to validate.
    /// - Returns: `true` if the key is valid, otherwise `false`.
    func validateAPIKey(_ apiKey: String) async -> Bool {
        var components = URLComponents(url: baseURL.appendingPathComponent("quote"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: "AAPL"),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        
        guard let url = components?.url else {
            return false
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return false
            }
            let json = String(decoding: data, as: UTF8.self)
            if json.contains("401") {
                return false
            } else {
                return true
            }
        } catch {
            return false
        }
    }
    
    /// Accounts with an Asset linked (with market sync enabled) will auto update their balances every 12h min
    @MainActor func updateAccountsIfMarketSync(accounts: [Account], context: ModelContext) {
        
        // Check last execution date
        let hoursSinceLastUpdate = Date().timeIntervalSince(AppIDs.lastMarketSyncUpdate) / 3600
        guard hoursSinceLastUpdate >= 12 else {
            print("⏸️ Market sync skipped (last update \(String(format: "%.1f", hoursSinceLastUpdate))h ago)")
            return
        }
        
        // Perform updates for accounts with market sync enabled
        let syncedAccounts = accounts.filter { $0.asset != nil }
        guard !syncedAccounts.isEmpty else { return }
        
        print("🔄 Updating market-synced accounts (\(syncedAccounts.count))...")
        
        for account in syncedAccounts {
            print("↳ Syncing account: \(account.name)")
            guard let asset = account.asset, let apiKey = AppIDs.twelveDataApiKey else { continue }
            Task(name: "MarketSync", priority: .background) {
                do {
                    let repo = MarketRepository()
                    let currentBalance = (account.currentBalance ?? 0).currencyAmount
                    let euroDollarRate = try await repo.fetchEURUSD(apiKey: apiKey)
                    let latestPrice = asset.latestPrice
                    let close = try await repo.fetchQuote(for: asset.symbol, exchange: asset.exchange, apiKey: apiKey).close
                    guard let close, let newPrice = Double(close) else { return }
                    asset.update(latestPrice: newPrice, euroDollarRate: euroDollarRate, context: context)
                    print("↳ Synced done for account: \(account.name) before: \(currentBalance), after: \(currentBalance) latestPrice: \(latestPrice) newPrice \(newPrice)")
                }
                catch {
                    print(error)
                }
            }
        }
        
        // Save last update date
        AppIDs.lastMarketSyncUpdate = Date()
        print("✅ Market sync completed and timestamp saved")
    }
}
