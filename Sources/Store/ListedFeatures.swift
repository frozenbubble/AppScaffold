import SwiftUI

@available(iOS 17.0, *)
public enum PlanComparisonValue {
    case present
    case missing
    case number(n: Int)
    case unlimited
}

@available(iOS 17.0, *)
public struct PlanCompareRow {
    let icon: String
    let name: String
    var description: String
    let basic: PlanComparisonValue
    let pro: PlanComparisonValue
    
    public init(
        icon: String,
        name: String,
        description: String,
        basic: PlanComparisonValue,
        pro: PlanComparisonValue
    ) {
        self.icon = icon
        self.name = name
        self.description = description
        self.basic = basic
        self.pro = pro
    }
}

@available(iOS 17.0, *)
struct PlanComparisonItem: View {
    let value: PlanComparisonValue
    
    public init(_ value: PlanComparisonValue) {
        self.value = value
    }

    var body: some View {
        switch value {
        case .present:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.accentColor)
        case .missing:
            Image(systemName: "x.circle.fill")
                .foregroundStyle(.secondary)
        case .number(let n):
            Text("\(n)")
                .foregroundStyle(.secondary)
        case .unlimited:
            Text("Unlimited")
                .foregroundStyle(Color.accentColor)
        }
    }
}

@available(iOS 17.0, *)
public struct ListedFeatures<HeaderContent: View, TrialContent: View>: View {
    let primaryBackgroundColor: Color
    let secondaryBackgroundColor: Color
    let features: [PlanCompareRow]
    let headerContent: HeaderContent
    let trialContent: TrialContent

    let screenWidth = UIScreen.main.bounds.width
    
    public init(
        primaryBackgroundColor: Color = Color(UIColor.systemBackground),
        secondaryBackgroundColor: Color = Color(UIColor.systemFill),
        features: [PlanCompareRow],
        @ViewBuilder headerContent: () -> HeaderContent,
        @ViewBuilder trialContent: () -> TrialContent = { EmptyView() }
    ) {
        self.primaryBackgroundColor = primaryBackgroundColor
        self.secondaryBackgroundColor = secondaryBackgroundColor
        self.features = features
        self.headerContent = headerContent()
        self.trialContent = trialContent()
    }
    
    struct SkewedRoundedRectangle: View {
        var body: some View {
            RoundedRectangle(cornerRadius: 8)
                .transformEffect(CGAffineTransform(a: 1, b: 0, c: -0.12, d: 1, tx: 0, ty: 0)) // Adjust 'c' for horizontal skew
        }
    }
    
    public var body: some View {
        ScrollView {
            ParalaxHeader(
                coordinateSpace: CoordinateSpaces.scrollView,
                defaultHeight: 350
            ) {
                headerContent
            }

            VStack {
                Text("Unlock all features with")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.top)
                HStack {
                    Text(AppScaffold.appName)
                        .font(.system(.title2, design: .rounded))
                    ZStack {
                        SkewedRoundedRectangle()
                            .foregroundStyle(LinearGradient(colors: [Color.accentColor, Color.accentColor], startPoint: .top, endPoint: .bottom))
                            .offset(x: 2)
                        
                        Text("Premium")
                            .padding(4)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
//                            .foregroundStyle(Color.systemGray4)
                            .foregroundStyle(.black)
                    }
                    .frame(maxWidth: 100)
                }
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 12)

                // Features
                VStack(spacing: 4) {
//                    Text("Features")
//                        .font(.title3)
//                        .fontWeight(.semibold)
//                        .padding(.bottom, 12)

                    ForEach(Array(features.enumerated()), id: \.offset) { (offset, element) in
                        let feature = element
                        
                        HStack(alignment: .top, spacing: 20) {
                            Image(systemName: feature.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(Color.accentColor)
                            VStack(alignment: .leading, spacing: 10) {
                                Text(feature.name).font(.headline)
                                Text(feature.description)
                            }
                            Spacer()
                        }
                        .padding(.leading)
                        .padding(.vertical)
                    }
                }
                .padding()
                
                // Trial
                trialContent

                Rectangle()
                    .frame(height: 150)
                    .foregroundStyle(.clear)
            }
            .frame(width: screenWidth)
            .background(primaryBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .offset(y: -50)
        }
        .coordinateSpace(name: CoordinateSpaces.scrollView)
        .edgesIgnoringSafeArea(.all)
        .background(secondaryBackgroundColor)
    }
}

@available(iOS 17.0, *)
#Preview {
    ListedFeatures(features: []) {
        Image(systemName: "heart")
            .resizable()
            .scaledToFit()
    }
    .accentColor(Color.yellow)
}

