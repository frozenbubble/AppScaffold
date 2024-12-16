import SwiftUI
import SwiftUIX

@available(iOS 16.0, *)
public struct ColoredLabelStyle: LabelStyle {
    var iconColor = Color.accentColor
    let textColor = Color.primary
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            VStack {
                configuration.icon
                    .foregroundColor(iconColor)
                    .font(.title2)
            }
            .frame(width: 30)
            
            configuration.title
                .foregroundColor(textColor)
        }
    }
}

//TODO: what's new page
@available(iOS 16.0, *)
public struct SettingsView: View {
    let appId: String
    
    @Environment(\.dismiss) var dismiss
    
    @State var displayNotificationsAlert = false
    @State var displayPaywall = false
    @State var displayDeleteAlert = false
    @State var displayLoginView = false
    
    @State var displayFeedback = false
    
    public init(appId: String) {
        self.appId = appId
    }
    
    public var body: some View {
        List {
            Section {
                NavigationLink {
                    WebView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"))
                } label: {
                    Label("Terms of Use", systemImage: "doc.plaintext").labelStyle(ColoredLabelStyle(iconColor: .cyan))
                }
                
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    Label("Privacy Policy", systemImage: "doc.text.magnifyingglass").labelStyle(ColoredLabelStyle(iconColor: .orange))
                }
                
                HStack {
                    Button {
                        displayPaywall = true
                    } label: {
                        HStack {
                            Label("Premium", systemImage: "crown").labelStyle(ColoredLabelStyle(iconColor: Color.accentColor))
                            Spacer()
                        }
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
//                .fullScreenPaywall(isPresented: $displayPaywall)
            }
            
            Section {
                if let appUrl = URL(string: "https://apps.apple.com/hu/app/id\(appId)") {
                    ShareLink(item: appUrl) {
                        Label("Share App", systemImage: "square.and.arrow.up").labelStyle(ColoredLabelStyle(iconColor: .cyan))
                    }
                    
                    HStack {
                        Button {
                            UIApplication.shared.open(appUrl)
                        } label: {
                            HStack {
                                Label("Rate us", systemImage: "star").labelStyle(ColoredLabelStyle(iconColor: .yellow))
                                Spacer()
                            }
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                
                HStack {
                    Button {
//                        sendEmailViaMailApp()
                        displayFeedback = true
                    } label: {
                        HStack {
                            Label("Feedback", systemImage: "text.bubble").labelStyle(ColoredLabelStyle(iconColor: Color.accentColor))
                            Spacer()
                        }
                    }
                    .sheet(isPresented: $displayFeedback) {
                        FeedbackView()
                            .padding(.top)
                            .presentationDetents([.fraction(0.42)])
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .navigationTitle("Settings")
//        .scrollContentBackground(.hidden)
//        .background(.editorBackground2)
//        .navigationBarBackButtonHidden()
//        .toolbar {
//            ToolbarItem(placement: .cancellationAction) {
//                Button {
//                    dismiss()
//                } label: {
//                    Image(systemName: "chevron.left.circle.fill")
//                }
//                .foregroundStyle(
//                    LinearGradient(colors: [.accent, .accent.darken(by: 0.2)], startPoint: .top, endPoint: .bottom)
//                )
//            }
//        }
        .task {
        }
    }
}

@available(iOS 16.0, *)
#Preview {
    NavigationStack {
        SettingsView(appId: "")
    }
}

