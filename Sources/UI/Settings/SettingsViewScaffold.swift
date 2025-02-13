import SwiftUI
import SwiftUIX

import AppScaffoldCore

@available(iOS 17.0, *)
public struct ColoredLabelStyle: LabelStyle {
    var iconColor = AppScaffold.colors.accent
    var textColor = Color.primary
    
    public init(iconColor: Color = AppScaffold.colors.accent, textColor: SwiftUICore.Color = Color.primary) {
        self.iconColor = iconColor
        self.textColor = textColor
    }
    
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

@available(iOS 17.0, *)
public extension LabelStyle where Self == ColoredLabelStyle {
    static func colored(iconColor: Color = AppScaffold.colors.accent, textColor: Color = .primary) -> Self {
        ColoredLabelStyle(iconColor: iconColor, textColor: textColor)
    }
}

//TODO: what's new page
//TODO: extract SettingsButton
@available(iOS 17.0, *)
public struct SettingsViewScaffold<TopContent: View, BotttomContent: View, PaywallContent: View>: View {
    let appId: String
    let topContent: TopContent
    let bottomContent: BotttomContent
    let paywallContent: PaywallContent
    
    let emailService = EmailService(feedbackEmail: AppScaffold.supportEmail, appName: AppScaffold.appName)
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @State var displayNotificationsAlert = false
    @State var displayPaywall = false
    @State var displayDeleteAlert = false
    @State var displayContactButton = false
    
    @State var displayFeedback = false
    
    public init(
        appId: String,
        @ViewBuilder topContent: () -> TopContent = { EmptyView() },
        @ViewBuilder bottomContent: () -> BotttomContent = { EmptyView() },
        paywallContent: () -> PaywallContent
    ) {
        self.appId = appId
        self.topContent = topContent()
        self.paywallContent = paywallContent()
        self.bottomContent = bottomContent()
        
        if appId.isEmpty {
            applog.warning("App Id not set, sharing and rating will not work.")
        }
    }
    
    public var body: some View {
        List {
            topContent
            
            Section {
                HStack {
                    Label("Theme", systemImage: "circle.lefthalf.filled").labelStyle(ColoredLabelStyle(iconColor: .primary))
                    Picker("", selection: $themeManager.theme) {
                        Text("System").tag(Theme.system)
                        Text("Light").tag(Theme.light)
                        Text("Dark").tag(Theme.dark)
                    }
                    .tint(.secondary)
                }
            }
            
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
                            Label("Premium", systemImage: "crown").labelStyle(ColoredLabelStyle(iconColor: .yellow))
                            Spacer()
                        }
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                .fullScreenCover(isPresented: $displayPaywall) {
                    paywallContent
                }
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
                        displayFeedback = true
                    } label: {
                        HStack {
                            Label("Feedback", systemImage: "text.bubble").labelStyle(ColoredLabelStyle(iconColor: AppScaffold.colors.accent))
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
                
                HStack {
                    Button {
                        emailService.sendEmailViaMailApp()
                    } label: {
                        HStack {
                            Label("Contact us", systemImage: "envelope").labelStyle(ColoredLabelStyle(iconColor: .green))
                            Spacer()
                        }
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            bottomContent
        }
        .tint(AppScaffold.accent)
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

@available(iOS 17.0, *)
#Preview {
    AppScaffold.useEventTracking()
    
    return NavigationStack {
        SettingsViewScaffold(appId: "") {
            Image(systemName: "person")
            
            Section {
                Text("Custom content")
            }
        } bottomContent: {
            Section {
                Text("Custom content")
            }
        } paywallContent: {
            EmptyView()
        }
    }
    .themeManager()
}

