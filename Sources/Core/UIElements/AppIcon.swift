import SwiftUI

struct AppIcon: View {
    var body: some View {
        ZStack {
            if let uIImage = UIImage(named: "AppIcon_1") {
                Image(uiImage: uIImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "square.dashed")
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

#Preview {
    AppIcon()
}
