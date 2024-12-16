import SwiftUI

enum CoordinateSpaces {
    case scrollView
}

@available(iOS 15.0, *)
public struct ParalaxHeader<Content: View, Space: Hashable>: View {
    let content: () -> Content
    let coordinateSpace: Space
    let defaultHeight: CGFloat
    
    public init(
        coordinateSpace: Space,
        defaultHeight: CGFloat,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.content = content
        self.coordinateSpace = coordinateSpace
        self.defaultHeight = defaultHeight
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let offset = offset(for: proxy)
            let heightModifier = heightModifier(for: proxy)
            let blurRadius = abs(offset) / 20 - (offset > 0 ? 3 : 0)
            
            content()
                .edgesIgnoringSafeArea(.horizontal)
                .frame(
                    width: proxy.size.width,
                    height: proxy.size.height + heightModifier
                )
                .offset(y: offset)
                .blur(radius: blurRadius)
        }.frame(height: defaultHeight)
    }
    
    private func offset(for proxy: GeometryProxy) -> CGFloat {
        let frame = proxy.frame(in: .named(coordinateSpace))
        if frame.minY < 0 {
            return -frame.minY * 0.8
        }
        return -frame.minY
    }
    
    private func heightModifier(for proxy: GeometryProxy) -> CGFloat {
        let frame = proxy.frame(in: .named(coordinateSpace))
        return max(0, frame.minY)
    }
}

@available(iOS 15.0, *)
#Preview {
    ScrollView() {
        ParalaxHeader(
            coordinateSpace: CoordinateSpaces.scrollView,
            defaultHeight: 350
        ) {
            Image(systemName: "nosign")
                .resizable()
                .scaledToFill()
        }
        
        VStack {
            Text("asdasdasd asd asd asd asd as  qwe")
                .font(.title)
            
            Rectangle()
                .fill(.blue)
                .frame(height: 1000)
        }
        .frame(maxWidth: .infinity)
        .background()
        

    }
    .background()
    .coordinateSpace(name: CoordinateSpaces.scrollView)
    .edgesIgnoringSafeArea(.all)
}
