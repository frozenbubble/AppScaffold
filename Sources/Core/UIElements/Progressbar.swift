import SwiftUI

@available(iOS 15.0, *)
public struct Progressbar: View {
    var height: CGFloat = 4
    var color1 = Color(red: 1.0, green: 1.0, blue: 0.96)
    var color2 = Color(red: 1.0, green: 1.0, blue: 0.96)
    @Binding var progress: Double
    
    public init(
        height: CGFloat = 4,
        color1: Color = Color(red: 1.0, green: 1.0, blue: 0.96),
        color2: Color = Color(red: 1.0, green: 1.0, blue: 0.96),
        progress: Binding<Double>
    ) {
        self.height = height
        self.color1 = color1
        self.color2 = color2
        self._progress = progress
    }
    
    public var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: g.size.width, height: height)
                    .foregroundColor(.black.opacity(0.1))
                
                Rectangle()
                    .frame(width: min(1, progress) * g.size.width, height: height)
                    .foregroundColor(.clear)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [color1, color2]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .clipped()
            }
        }
        .frame(height: height)
    }
}

@available(iOS 15.0, *)
#Preview {
    struct PreviewWrapper: View {
        @State var progress = 0.2
        
        var body: some View {
            VStack {
                Progressbar(height: 6, progress: $progress)
                    .animation(.spring(), value: progress)
                
                Button("Move") {
                    progress += 0.1
                }
            }
        }
    }
    
    return ZStack {
        Color.accentColor
            .ignoresSafeArea()
        PreviewWrapper()
            .foregroundStyle(.white)
            .padding()
    }
}

