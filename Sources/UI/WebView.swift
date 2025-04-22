import SwiftUI
import WebKit

import AppScaffoldCore

@available(iOS 15.0, *)
public struct WebView: UIViewRepresentable {
    let url: URL?
    // Optional callback for when loading finishes successfully
    var onLoadFinished: (() -> Void)? = nil

    public init(url: URL?, onLoadFinished: (() -> Void)? = nil) {
        self.url = url
        self.onLoadFinished = onLoadFinished
    }

    // Coordinator to act as the WKNavigationDelegate
    public class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        // Called when the navigation is complete
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Execute the callback provided by the parent struct
            parent.onLoadFinished?()
        }

        // Optional: Handle load failures if necessary
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            // The onLoadFinished callback is *not* called on failure
            applog.error("WebView failed navigation: \(error.localizedDescription)")
        }
         public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
             // Also not called on provisional navigation failure
             applog.error("WebView failed provisional navigation: \(error.localizedDescription)")
        }
    }

    // Create the Coordinator
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Create the WKWebView and set the delegate
    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator // Set delegate

        // Load the URL if provided
        if let url = url {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    // Update the view if the URL changes
    public func updateUIView(_ webView: WKWebView, context: Context) {
        // Check if the URL has changed and needs reloading
        if let newURL = url, webView.url != newURL {
            // Avoid reloading if the webView is already loading the new URL
            // Note: webView.url might be nil initially or during redirects
            if webView.isLoading == false || webView.url?.absoluteString != newURL.absoluteString {
                 webView.load(URLRequest(url: newURL))
            }
        } else if url == nil && webView.url != nil {
            // Handle case where URL becomes nil
            webView.loadHTMLString("", baseURL: nil) // Load blank page
        }
    }
}

public struct LoadingWebView: View {
    let url: URL?
    
    @State var busy: Bool = true
    
    public init(url: URL?) {
        self.url = url
    }
    
    public var body: some View {
        ZStack {
            if url == nil {
                VStack {
                    Image(systemName: "nosign")
                    Text("Invalid URL.")
                }
                .foregroundStyle(.secondary)
            } else {
                WebView(url: url) {
                    withAnimation { self.busy = false }
                }
                .opacity(busy ? 0 : 1)
                
                if busy {
                    LoadingIndicator(animation: .bar, color: AppScaffoldUI.accent)
                }
            }
        }
    }
}

// --- Example Usage Preview ---
@available(iOS 15.0, *)
#Preview {
    struct PreviewWrapper: View {
        private let url = URL(string: "https://swift.org")

        var body: some View {
            VStack {
                LoadingWebView(url: url)
            }
        }
    }

    return PreviewWrapper()
}
