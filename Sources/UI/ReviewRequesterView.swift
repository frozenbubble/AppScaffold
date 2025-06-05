#if os(iOS)

import SwiftUI
import Resolver
import StoreKit
import Mixpanel

import AppScaffoldCore
import AppScaffoldAnalytics

@available(iOS 17.0, *)
enum IssueType: String, Identifiable, CaseIterable {
    case userExperience = "User Experience"
    case featureRequest = "Feature Request"
    case bug = "Report a Bug"
    case general = "General Feedback"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .userExperience:
            return "gear"
        case .featureRequest:
            return "lightbulb"
        case .bug:
            return "exclamationmark.triangle"
        case .general:
            return "bubble.left"
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
    var title: String
    var unifiedCompletion: Bool
    var onCompletion: (() -> Void)?

    @Environment(\.dismiss) var dismiss
    @AppService var tracking: EventTrackingService

    @State var issueType: IssueType? = nil
    @State var feedback: String = ""

    public init(title: String = "What best describes your experience?", unifiedCompletion: Bool = false, onCompletion: (() -> Void)? = nil) {
        self.title = title
        self.unifiedCompletion = unifiedCompletion
        self.onCompletion = onCompletion
    }

    public var body: some View {
        ZStack {
            if issueType != nil {
                feedbackForm
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                issueTypeSelector
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .padding(.top)
        .frame(maxWidth: .infinity)
        .onAppear {}
    }

    var issueTypeSelector: some View {
        VStack(spacing: 24) {
            Text("How can we improve your experience?")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(IssueType.allCases) { type in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            issueType = type
                        }
                        tracking.trackEvent("User Issue", [ "Type": type.rawValue ], isAction: false)
                    } label: {
                        HStack {
                            Image(systemName: type.icon)
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 24)
                            Text(type.rawValue)
//                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.leading, 4)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .fontWeight(.semibold)
                                .font(.callout)
                                .opacity(0.85)
                        }
                    }
                    .buttonStyle(FeedbackButtonStyle())
                }
            }
            .padding(.horizontal)
            .foregroundStyle(.white)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    var feedbackForm: some View {
        VStack(spacing: 20) {
            HStack {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        issueType = nil
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundStyle(AppScaffoldUI.accent)
                }

                Spacer()

                Text(issueType?.feedbackFormTitle ?? "")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                // Empty view for balanced spacing
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .opacity(0)
            }
            .padding(.horizontal)

            TextEditor(text: $feedback)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .frame(maxWidth: .infinity, minHeight: 220)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .padding(.horizontal)

            Button {
                tracking.trackEvent("Written Feedback", [
                    "Type": issueType?.rawValue ?? "",
                    "Feedback": feedback
                ])

                if unifiedCompletion {
                    // Navigate to completion view
                    onCompletion?()
                } else {
                    withAnimation {
                        self.issueType = nil
                        dismiss()
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Submit")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [AppScaffoldUI.colors.accent.darken(by: 0.05), AppScaffoldUI.colors.accent
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: AppScaffoldUI.accent.opacity(0.3), radius: 5, y: 2)
            }
            .padding(.horizontal)
            .buttonStyle(ScaleButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

@available(iOS 17.0, *)
public struct ReviewRequesterView: View {
    var onNegativeFeedback: (() -> Void)?
    var unifiedCompletion: Bool
    var onDismiss: (() -> Void)?

    public init(onNegativeFeedback: (() -> Void)? = nil, unifiedCompletion: Bool = false, onDismiss: (() -> Void)? = nil) {
        self.onNegativeFeedback = onNegativeFeedback
        self.unifiedCompletion = unifiedCompletion
        self.onDismiss = onDismiss
    }

    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    @AppService var tracking: EventTrackingService

    @State var displayFeedbackRequest = false
    @State var showCompletion = false

    public var body: some View {
        ZStack {
            if showCompletion {
                completionView
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            } else if displayFeedbackRequest {
                FeedbackView(unifiedCompletion: unifiedCompletion) {
                    // Called when feedback is submitted and unifiedCompletion is true
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        displayFeedbackRequest = false
                        showCompletion = true
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                feedbackSelector
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .tint(AppScaffoldUI.accent)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onDisappear {
            onDismiss?()
        }
    }

    var completionView: some View {
        VStack(spacing: 32) {
            // App Icon and header
            VStack(spacing: 16) {
                AppIcon(imageName: "AppIcon_1")
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(.systemGray5), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)

                VStack(spacing: 8) {
                    Text("Thank you!")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("If you like \(AppScaffold.appName) and have the time, a review or a quick rating would mean the world to us!")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
//                        .frame(height: 50)
                        .lineLimit(3)
//                        .frame(maxHeight: .infinity)
                }
            }
            .padding(.top, 12)

            // Action buttons
            VStack(spacing: 16) {
                // Write Review button
                Button {
                    tracking.trackEvent("Review Action", ["Action": "write_review"], isAction: false)
                    openAppStoreReview()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Write Review")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                }
                .buttonStyle(FeedbackButtonStyle())

                // Rate App button
                Button {
                    tracking.trackEvent("Review Action", ["Action": "rate_app"], isAction: false)
                    requestReview()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Rate App")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                }
                .buttonStyle(FeedbackButtonStyle())
            }
            .foregroundStyle(.white)

            // Not now button
            Button {
                tracking.trackEvent("Review Action", ["Action": "not_now"])
                dismiss()
            } label: {
                Text("Not now")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }

    var feedbackSelector: some View {
        VStack(spacing: 28) {
            // App Icon
            VStack(spacing: 8) {
                AppIcon(imageName: "AppIcon_1")
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(.systemGray5), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                    .padding(.bottom, 8)

                Text("Enjoying \(AppScaffold.appName)?")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .padding(.top, 12)

            // Response buttons
            HStack(spacing: 24) {
                // Negative feedback button
                Button {
                    tracking.trackEvent("Feedback", [ "Sentiment": "negative" ])
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        displayFeedbackRequest = true
                    }
                } label: {
                    VStack(spacing: 12) {
                        Text("🙁")
                            .font(.system(size: 42))
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color(.systemGray6))
                            )

                        Text("Could be better")
                            .font(.callout)
                            .fontWeight(.medium)
                    }
                    .frame(width: 130)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.secondarySystemGroupedBackground)
                            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(.systemGray5), lineWidth: 1)
                    )
                }
                .buttonStyle(ScaleButtonStyle())

                // Positive feedback button
                Button {
                    tracking.trackEvent("Feedback", [ "Sentiment": "positive" ])
                    if unifiedCompletion {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showCompletion = true
                        }
                    } else {
                        withAnimation {
                            dismiss()
                        }
                        requestReview()
                    }
                } label: {
                    VStack(spacing: 12) {
                        Text("😍")
                            .font(.system(size: 42))
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(.pink.opacity(0.15))
                            )

                        Text("Loving it!")
                            .font(.callout)
                            .fontWeight(.medium)
                    }
                    .frame(width: 130)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.secondarySystemGroupedBackground)
                            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(.systemGray5), lineWidth: 1)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 24)
    }

    /// Opens the App Store review page for the current app
    private func openAppStoreReview() {
        if let url = URL(string: "https://apps.apple.com/app/id\(AppScaffold.appId)?action=write-review"),
              !AppScaffold.appId.isEmpty,
              UIApplication.shared.canOpenURL(url) {
            applog.debug("Opening App Store review page for \(AppScaffold.appId)...")
            UIApplication.shared.open(url)
        } else {
            applog.error("Could not open App Store review page: Invalid App ID or URL scheme not supported...")
            requestReview()
        }
    }
}

@available(iOS 17.0, *)
public struct FeedbackButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 12
    var padding: CGFloat = 12

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(padding)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppScaffoldUI.colors.actionButtonColor1,
                                AppScaffoldUI.colors.actionButtonColor2,
                            ],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    )
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .shadow(color: AppScaffoldUI.accent.opacity(0.3), radius: 3, y: 2)
    }
}

/// Adds a subtle scale animation when button is pressed
@available(iOS 17.0, *)
public struct ScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

@available(iOS 17.0, *)
public extension View {
    func reviewRequester(isPresented: Binding<Bool>, unifiedCompletion: Bool = false, onDismiss: (() -> Void)? = nil) -> some View {
        modifier(ReviewRequesterModifier(isPresented: isPresented, unifiedCompletion: unifiedCompletion, onDismiss: onDismiss))
    }

    func autoReviewRequester(unifiedCompletion: Bool = false, onDismiss: (() -> Void)? = nil) -> some View {
        modifier(AutoReviewRequesterModifier(unifiedCompletion: unifiedCompletion, onDismiss: onDismiss))
    }
}

@available(iOS 17.0, *)
struct ReviewRequesterModifier: ViewModifier {
    @Binding var isPresented: Bool
    var unifiedCompletion: Bool
    var onDismiss: (() -> Void)?

    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                ReviewRequesterView(unifiedCompletion: unifiedCompletion, onDismiss: onDismiss)
                    .presentationDetents([.medium])
            }
            .onDisappear { isPresented = false }
    }
}

@available(iOS 17.0, *)
struct AutoReviewRequesterModifier: ViewModifier {
    @AppStorage(AppScaffoldStorageKeys.displayReviewRequest, store: .scaffold) private var displayReviewRequest: Bool = false
    var unifiedCompletion: Bool
    var onDismiss: (() -> Void)?

    public func body(content: Content) -> some View {
        content
            .reviewRequester(isPresented: $displayReviewRequest, unifiedCompletion: unifiedCompletion, onDismiss: onDismiss)
    }
}

@available(iOS 17.0, *)
fileprivate struct ReviewRequesterPreview: View {
    @State var present: Bool = false
    @State var presentUnified: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Button("Present (Legacy)") { present.toggle() }
            Button("Present (Unified)") { presentUnified.toggle() }
        }
        .reviewRequester(isPresented: $present, unifiedCompletion: false)
        .reviewRequester(isPresented: $presentUnified, unifiedCompletion: true)
    }
}

@available(iOS 17.0, *)
#Preview {
    AppScaffold.configure(appName: "Test App", appId: "6711358397")
    AppScaffold.useConsoleLogger(minLevel: .verbose, logPrintWay: .print)
    AppScaffold.configureUI(colors: .init(accent: Color.cyan), defaultTheme: .system)

    AppScaffold.useEventTracking()

    return ReviewRequesterPreview()
}

#endif
