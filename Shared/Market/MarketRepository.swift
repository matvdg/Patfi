import Foundation

enum TwelveDataError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

class MarketRepository {
    
    // TwelveData free plan
    private let apiKey = "589930dcbf5547c69e9d8b716181e79e"
    private let baseURL = URL(string: "https://api.twelvedata.com")!
    
    /// Fetches the latest quote for a given symbol from Twelve Data API.
    /// - Parameter symbol: The ticker symbol to fetch.
    /// - Parameter exchange: The optional exchange code.
    /// - Returns: QuoteResponse with symbol, name, price, and currency.
    func fetchQuote(for symbol: String, exchange: String? = nil) async throws -> QuoteResponse {
        var fullSymbol = symbol
        if let exchange = exchange, !exchange.isEmpty {
            fullSymbol += ":\(exchange)"
        }
        // Construct the URL for the quote endpoint
        var components = URLComponents(url: baseURL.appendingPathComponent("quote"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: fullSymbol),
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
        //        if let jsonString = String(data: data, encoding: .utf8) {
        //            print("🧾 JSON Response:\n\(jsonString)")
        //        }
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
    func searchQuotes(query: String) async throws -> [QuoteResponse] {
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
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("🧾 JSON Response:\n\(jsonString)")
//        }
        do {
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(SymbolSearchResponse.self, from: data)
            return searchResponse.data
        } catch {
            throw TwelveDataError.decodingFailed
        }
    }
}
