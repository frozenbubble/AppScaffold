import SwiftUI
import PhotosUI

@available(iOS 17.0, *)
public struct ProfilePicturePicker: View {
    private let onPick: ((Data) -> Void)?
    
    init(onInit: @escaping () -> Data?, onPick: ((Data) -> Void)? = nil) {
        if let data = onInit() {
            _avatar = .init(initialValue: Image(data: data))
        }
        
        self.onPick = onPick
    }
    
//    convenience init(cloudKey: String) {
//        self.init { nil }
//    }
    
    @State var avatar: Image? = nil
    @State var pickedPhoto: PhotosPickerItem?
    
    public var body: some View {
        let capturedAvatar = avatar
        
        PhotosPicker(selection: $pickedPhoto, matching: .images) {
            if let capturedAvatar {
                capturedAvatar
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .background {
                        Circle().fill(.white)
                            .padding(2)
                    }
            }
        }
        .disabled(onPick == nil)
        .frame(maxWidth: 256, maxHeight: 256)
        .clipShape(Circle())
        .contentShape(Circle())
        .onChange(of: pickedPhoto) {
            Task {
                if let pickedPhoto,
                   let data = try? await pickedPhoto.loadTransferable(type: Data.self),
                   let uIImage = UIImage(data: data) {
                    withAnimation { avatar = Image(uiImage: uIImage) }
//                    let store = NSUbiquitousKeyValueStore.default
//                    store.set(data, forKey: Self.avatarDataKey)
                    onPick?(data)
                }
            }
        }
//        .task {
//            let store = NSUbiquitousKeyValueStore.default
//            if let imageData = store.data(forKey: Self.avatarDataKey),
//               let uIImage = UIImage(data: imageData)?.resize(256, 256) {
//                avatar = Image(uiImage: uIImage)
//            }
//        }
    }
}

@available(iOS 17.0, *)
#Preview {
    ProfilePicturePicker {
        let store = NSUbiquitousKeyValueStore.default
        return store.data(forKey: "key")
    } onPick: { _ in }
    .frame(width: 160, height: 160)
    .foregroundStyle(.yellow)
}
