import SwiftUI

@available(iOS 15.0, *)
public struct DividedVStack<Content: View>: View {
    var spacing: CGFloat
    var content: Content

    public init(spacing: CGFloat = 0, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        _VariadicView.Tree(DividedVStackLayout(spacing: spacing)) {
            content
        }
    }
}

@available(iOS 15.0, *)
struct DividedVStackLayout: _VariadicView_UnaryViewRoot {
    var spacing: CGFloat

    public init(spacing: CGFloat) {
        self.spacing = spacing
    }

    @ViewBuilder
    public func body(children: _VariadicView.Children) -> some View {
        let last = children.last?.id

        VStack(spacing: spacing) {
            ForEach(children) { child in
                child

                if child.id != last {
                    Divider()
                }
            }
        }
    }
}
