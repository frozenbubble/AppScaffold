import SwiftUI
import MarkdownUI

import AppScaffoldCore

@available(iOS 17.0, *)
public struct PrivacyPolicyView: View {
    @State var privacy = ""
    
    public init() { }
    
    public var body: some View {
        ScrollView {
            if !privacy.isEmpty {
                Markdown(privacy)
                    .padding(.horizontal)
            } else {
                VStack {
                    Text("Could not load privacy policy").padding()
                }
            }
        }
        .task {
            getContents()
        }
    }
    
    func getContents() {
        if let filepath = Bundle.main.path(forResource: "privacy", ofType: "md") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let contentsWithAppName = contents.replacingOccurrences(of: "<<App Name>>", with: AppScaffold.appName)
                
                privacy = contentsWithAppName
            } catch {
                applog.error("Privacy policy contents could not be loaded")
                // contents could not be loaded
            }
        } else {
            applog.error("Privacy policy not found")
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    PrivacyPolicyView()
}
