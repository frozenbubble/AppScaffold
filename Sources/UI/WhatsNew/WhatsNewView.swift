import SwiftUI

@available(iOS 17.0, *)
struct WhatsNewView: View {
    let manager: WhatsNewManager

    private let maxPopupHeight: CGFloat = 440

    var body: some View {
        VStack(spacing: 20) {
            Text("What's New")
                .font(.title)
                .bold()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(manager.items) { item in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: item.icon)
                                .font(.title2)
                                .foregroundColor(AppScaffoldUI.accent)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: maxPopupHeight * 0.6)

            Button("Got it!") {
                manager.dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10)
        .padding()
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: maxPopupHeight)
    }
}

@available(iOS 17.0, *)
#Preview {
    let items = [
        WhatsNewItem(
            title: "New Dashboard",
            description: "Redesigned dashboard with better insights",
            icon: "chart.bar.fill"
        ),
        WhatsNewItem(
            title: "Dark Mode",
            description: "Added support for dark mode",
            icon: "moon.fill"
        ),
        WhatsNewItem(
            title: "Offline Support",
            description: "Work offline and sync when back online",
            icon: "wifi.slash"
        )
    ]

    return WhatsNewView(manager: WhatsNewManager(currentVersion: "1.0.0", items: items))
        .preferredColorScheme(.dark)
}
