import SwiftUI

@available(iOS 15.0, *)
public struct AppIcon: View {
    let imageName: String
    
    public init(imageName: String = "AppIcon_1") {
        self.imageName = imageName
    }
    
    public var body: some View {
        ZStack {
            if let uIImage = UIImage(named: imageName) {
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
