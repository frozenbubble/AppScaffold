import SwiftUI
import Resolver
import StoreKit
import Mixpanel

@available(iOS 17.0, *)
enum IssueType: String, Identifiable, CaseIterable {
    case userExperience = "User Experience"
    case featureRequest = "Feature Request"
    case bug = "Report a Bug"
    case general = "General Feedback"

    var id: String { self.rawValue }
    
    var emoji: String {
        switch self {
        case .userExperience:
            return "🧑‍💻"
        case .featureRequest:
            return "🔍"
        case .bug:
            return "🐞"
        case .general:
            return "💡"
        }
    }
    
    var feedbackFormTitle: String {
        switch self {
        case .userExperience:
            return "How can we improve?"
        case .featureRequest:
            return "What feature would you like to see?"
        case .bug:
            return "What issue did you encounter?"
        case .general:
            return "How can we help?"
        }
    }
}

@available(iOS 17.0, *)
public struct FeedbackView: View {
    var title: String// = "What best describes your experience?"
    
    @Environment(\.dismiss) var dismiss
    @AppService var tracking: EventTrackingService
    
    @State var issueType: IssueType? = nil
    @State var feedback: String = ""
    
    public init(title: String = "What best describes your experience?") {
        self.title = title
    }

    public var body: some View {
        ZStack {
            if issueType != nil {
                feedbackForm.transition(.move(edge: .bottom))
            } else {
                issueTypeSelector
            }
        }
        .transition(.move(edge: .bottom))
        .onAppear {
            
        }
    }
    
    var issueTypeSelector: some View {
        VStack(spacing: 30) {
            Text("How can we improve your experience?")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(IssueType.allCases) { type in
                    Button {
                        withAnimation {
                            issueType = type
                        }
                        tracking.trackEvent("User Issue", [ "Type": type.rawValue ])
                    } label: {
                        HStack {
                            Text(type.emoji)
                            Text(type.rawValue)
                        }
                    }
                    .buttonStyle(FeedbackButtonStyle())
                }
            }
            .foregroundStyle(.white)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
    
    var feedbackForm: some View {
        ZStack {
            if let issueType {
                VStack(spacing: 12) {
                    Text(issueType.feedbackFormTitle)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $feedback)
                        .scrollContentBackground(.hidden) // <- Hide it
                        .background(.secondary.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button {
                        self.issueType = nil
                        dismiss()
                        tracking.trackEvent("Written Feedback", [
                            "Type": issueType.rawValue,
                            "Feedback": feedback
                        ])
                    } label: {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Submit")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppScaffold.colors.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
            }
        }
    }
}

@available(iOS 17.0, *)
public struct ReviewRequesterView: View {
    var onNegativeFeedback: (() -> Void)?
    
    public init(onNegativeFeedback: (() -> Void)? = nil) {
        self.onNegativeFeedback = onNegativeFeedback
    }

    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    @AppService var tracking: EventTrackingService

    @State var displayFeedbackRequest = false
    
    public var body: some View {
        ZStack {
            if displayFeedbackRequest {
                FeedbackView()
            } else {
                feedbackSelector
            }
        }
        .tint(AppScaffold.colors.accent)
        .frame(maxWidth: .infinity)
    }
    
    var feedbackSelector: some View {
        VStack {
            Image("AppIcon_1")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
                .shadow(radius: 3)

            Text("Enjoying \(AppScaffold.appName)?")
                    .font(.title2)
                    .fontWeight(.semibold)

                HStack(spacing: 22) {
                    Button {
                        tracking.trackEvent("Feedback", [ "Sentiment": "negative" ])
                        withAnimation {
                            displayFeedbackRequest = true
                        }
                    } label: {
                        VStack(spacing: 16) {
                            Text("🙁")
                                .font(.title)
                            Text("Could be better")
                        }
                    }
                    .frame(width: 140, height: 140)

                    Button {
                        tracking.trackEvent("Feedback", [ "Sentiment": "positive" ])
                        dismiss()
                        requestReview()
                    } label: {
                        VStack(spacing: 16) {
                            Text("😍")
                                .font(.title)
                            Text("Loving it!")
                        }
                    }
                    .padding()
                    .frame(width: 140, height: 140)
                }
        }
        .frame(maxWidth: .infinity)
    }
}


@available(iOS 17.0, *)
public struct FeedbackButtonStyle: ButtonStyle {
    // Custom properties for your button style
//    var backgroundColor: Color = .blue
//    var foregroundColor: Color = .white
    var cornerRadius: CGFloat = 32
    var padding: CGFloat = 12

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .fontWeight(.medium)
//            .foregroundStyle(.white)
            .padding(padding)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppScaffold.accent)
//                    .fill(.secondary)
//                    .stroke(
//                        AppScaffold.colors.accent,
//                        lineWidth: 3
//                    )
            )
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .padding(.horizontal, 20)
//            .foregroundColor(foregroundColor)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Scale effect when pressed
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

@available(iOS 17.0, *)
public extension View {
    func reviewRequester(isPresented: Binding<Bool>) -> some View {
        self
            .sheet(isPresented: isPresented) {
                ReviewRequesterView()
                    .padding(.top)
                    .presentationDetents([.medium])
//                    .background(.editorBackground2.darken(by: 0.08))
            }
    }
}

@available(iOS 17.0, *)
fileprivate struct ReviewRequesterPreview: View {
    @State var present: Bool = false
    
    var body: some View {
        ZStack {
            Button("Present") {
                present.toggle()
            }
        }
        .reviewRequester(isPresented: $present)
    }
}

@available(iOS 17.0, *)
#Preview {
//    Resolver.register { EventTrackingService(thresholds: [10, 100]) }.scope(.shared)
    AppScaffold.configure(appName: "AppScaffold", colors: .init(accent: Color.systemYellow))
    
    AppScaffold.useEventTracking()
    
    return ReviewRequesterPreview()
}

