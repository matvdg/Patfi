import SwiftUI
import WebKit

struct TwelveDataView: View {
    
    @State private var apiKey: String = ""
    @State private var showEmptyError: Bool = false
    @State private var showApiError: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("""
                 To use "Market Sync" ßeta feature, you need to provide a Twelve Data API key.
                 Creating one is quick and free with Apple Sign In.
                 This allows Patfi to stay completely free, with no ads or subscriptions.
                 """)
            .multilineTextAlignment(.leading)
                .font(.body)
            
            NavigationLink {
                TwelveDataWebView(urlString: "https://twelvedata.com/login")
            } label: {
                Label("Sign in to Twelve Data", systemImage: "safari")
            }

            
            Button {
                if let clipboard = UIPasteboard.general.string {
                    Task {
                        let repo = MarketRepository()
                        print("📋 Clipboard = \(clipboard)")
                        let isValid = await repo.validateAPIKey(clipboard)
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
                Label("Clipboard is empty — please copy your API key first", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.subheadline)
            }
            if showApiError {
                Label("Invalid API key — please check and try again", systemImage: "xmark.octagon.fill")
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
        .navigationTitle("Twelve Data API Key")
        .padding()
    }
}

struct TwelveDataWebView: View {
    let urlString: String

    var body: some View {
        if let url = URL(string: urlString) {
            WebView(url: url)
                .navigationTitle("Twelve Data")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            UIApplication.shared.open(url)
                        } label: {
                            Image(systemName: "safari")
                        }
                    }
                }
        } else {
            ContentUnavailableView(
                "Invalid URL",
                systemImage: "exclamationmark.triangle",
                description: Text("The provided Twelve Data URL is not valid.")
            )
        }
    }
}

#Preview {
    NavigationStack {
        TwelveDataView()
    }
}
