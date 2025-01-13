import SwiftUI

@available(iOS 16.4, *)
public struct ShrinkingScrollView<Content: View>: View {
    let axes: Axis.Set
    let spacing: Double
    let content: Content
    
    init(_ axes: Axis.Set = .vertical, spacing: Double = 10, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.spacing = spacing
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            switch axes {
            case .horizontal:
                OptimalWidth {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: spacing) {
                            content
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
                }
                
            case .vertical:
                OptimalHeight {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: spacing) {
                            content
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize, axes: .vertical) //We are > iOS 16.4
                }
            default:
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
            }
        }
    }
    
    struct OptimalHeight: Layout {
        public func sizeThatFits(
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache: inout ()
        ) -> CGSize {
            let result: CGSize
            if let firstSubview = subviews.first {
                let containerWidth = proposal.width ?? .infinity
                let containerHeight = proposal.height ?? .infinity
                let size = firstSubview.sizeThatFits(.init(width: containerWidth, height: nil))
                result = CGSize(width: containerWidth, height: min(size.height, containerHeight))
            } else {
                result = .zero
            }
            return result
        }
        
        public func placeSubviews(
            in bounds: CGRect,
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache: inout ()
        ) {
            if let firstSubview = subviews.first {
                firstSubview.place(
                    at: CGPoint(x: bounds.minX, y: bounds.minY),
                    proposal: .init(width: bounds.width, height: bounds.height)
                )
            }
        }
    }
    
    struct OptimalWidth: Layout {
        public func sizeThatFits(
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache: inout ()
        ) -> CGSize {
            let result: CGSize
            if let firstSubview = subviews.first {
                let containerWidth = proposal.width ?? .infinity
                let containerHeight = proposal.height ?? .infinity
                let size = firstSubview.sizeThatFits(.init(width: nil, height: containerHeight))
                result = CGSize(width: min(size.width, containerWidth), height: containerHeight)
            } else {
                result = .zero
            }
            return result
        }
        
        public func placeSubviews(
            in bounds: CGRect,
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache: inout ()
        ) {
            if let firstSubview = subviews.first {
                firstSubview.place(
                    at: CGPoint(x: bounds.minX, y: bounds.minY),
                    proposal: .init(width: bounds.width, height: bounds.height)
                )
            }
        }
    }
}

@available(iOS 16.4, *)
#Preview {
    ShrinkingScrollView(.horizontal) {
        Rectangle()
            .fill(.red)
            .frame(width: 100, height: 100)
        Rectangle()
            .fill(.red)
            .frame(width: 100, height: 100)
        Rectangle()
            .fill(.red)
            .frame(width: 100, height: 100)
        Rectangle()
            .fill(.red)
            .frame(width: 100, height: 100)
        Rectangle()
            .fill(.red)
            .frame(width: 100, height: 100)
    }
    .frame(height: 100)
    .background(.blue)
}
