import SwiftUI

//TODO: move to proper place
public struct InfoAlertModifier: ViewModifier {
    let title: String
    let message: String
    @Binding var isPresented: Bool
    let action: () -> Void

    public func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented) {
                Button("OK") {
                    isPresented = false
                    action()
                }
            } message: {
                Text(message)
            }
    }
}

// 2. Create the View extension for easy usage
public extension View {
    /// Presents an alert with a title, message, and a single "OK" button.
    ///
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The informative message body of the alert.
    ///   - isPresented: A binding to a Boolean value that determines whether
    ///     to present the alert. When the user taps the "OK" button, this
    ///     value is set to `false` and the alert is dismissed.
    ///   - action: The closure to execute when the "OK" button is tapped.
    func infoAlert(
        _ title: String,
        message: String,
        isPresented: Binding<Bool>,
        action: @escaping () -> Void = {} // Default to empty action
    ) -> some View {
        self.modifier(
            InfoAlertModifier(
                title: title,
                message: message,
                isPresented: isPresented,
                action: action
            )
        )
    }
}

struct Sandbox: View {
    @State var displayAlert: Bool = true
    
    var body: some View {
        Text("Hello, World!").font(.headline).fontWeight(.light)
            .infoAlert("Hi", message: "This is a message", isPresented: $displayAlert) {
                displayAlert = false
            }
    }
}

#Preview {
    Sandbox()
}
