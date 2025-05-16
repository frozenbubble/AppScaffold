#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import SwiftUI

@available(iOS 16.0, *)
public struct OnboardingBuilder: View {


    public var body: some View {
        EmptyView()
    }
}

@available(iOS 16.0, *)
fileprivate struct DummyScreen1: View {
    var body: some View {
        OnboardingScreen(title: "Dummy1", subTitle: "") {

        }
    }
}

@available(iOS 16.0, *)
fileprivate struct DummyScreen2: View {
    var body: some View {
        OnboardingScreen(title: "Dummy2", subTitle: "") {

        }
    }
}

@available(iOS 16.0, *)
#Preview {
    OnboardingBuilder()
    // OnboardingBuilder {
    //     SomeScreen() {  }
    // }
}
#endif
