import SwiftUI
import MarkdownUI

@available(iOS 17.0, *)
struct PrivacyPolicyView: View {
    @State var privacy = ""
    
    var body: some View {
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
                print("catch")
                // contents could not be loaded
            }
        } else {
            print("not found")
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    PrivacyPolicyView()
}
