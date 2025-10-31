import SwiftUI
import WebKit

struct TwelveDataView: View {
    
    @State private var apiKey: String = ""
    @State private var showEmptyError: Bool = false
    @State private var showApiError: Bool = false
    
    private let marketRepository = MarketRepository()
    
    var body: some View {
        VStack(spacing: 24) {
            BetaBadge()
            Text("TwelveDataFeatureDescription")
            .multilineTextAlignment(.leading)
                .font(.body)
            
            NavigationLink {
                TwelveDataWebView(urlString: "https://twelvedata.com/login")
            } label: {
                Label("SignInToTwelveData", systemImage: "safari")
            }

            
            Button {
#if canImport(UIKit)
                let clipboard = UIPasteboard.general.string
#elseif canImport(AppKit)
                let clipboard = NSPasteboard.general.string(forType: .string)
#endif
                if let clipboard {
                    Task {
                        print("📋 Clipboard = \(clipboard)")
                        let isValid = await marketRepository.validateAPIKey(clipboard)
                        if !isValid {
                            showApiError = true
                        } else {
                            showApiError = false
                            apiKey = clipboard
                            AppIDs.twelveDataApiKey = apiKey
                        }
                    }
                } else {
                    showEmptyError = true
                }
            } label: {
                Label("Paste API Key", systemImage: "doc.on.clipboard")
            }
            .buttonStyle(.bordered)
            
            if showEmptyError {
                Label("ErrorInvalidClipboard", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.subheadline)
            }
            if showApiError {
                Label("ErrorInvalidApiKey", systemImage: "xmark.octagon.fill")
                    .foregroundStyle(.red)
                    .font(.subheadline)
            }
            
            if !apiKey.isEmpty {
                VStack(spacing: 8) {
                    Text(apiKey)
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .imageScale(.large)
                }
                .transition(.opacity)
            }
            
            Spacer()
        }
        .navigationTitle("TwelveDataApiKey")
        .padding()
    }
}

struct TwelveDataWebView: View {
    let urlString: String

    var body: some View {
        let url = URL(string: urlString)!
        WebView(url: url)
            .navigationTitle("Twelve Data")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

#Preview {
    NavigationStack {
        TwelveDataView()
    }
}
