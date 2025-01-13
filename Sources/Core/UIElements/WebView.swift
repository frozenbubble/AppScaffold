import SwiftUI
import WebKit

@available(iOS 15.0, *)
public struct WebView: UIViewRepresentable{
    var url:URL? = nil
    
    public init(url: URL?){
        self.url = url
    }
    
    public func makeUIView(context: Context) -> some UIView {
        guard let url else {
            return WKWebView()
        }
        let webview = WKWebView()
        webview.load(URLRequest(url: url))
        return webview
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

@available(iOS 15.0, *)
#Preview {
    WebView(url: URL(string: "https://blender.org"))
}
