import SwiftUI
//import UIKit

import AppScaffoldCore
import AppScaffoldUI

@available(iOS 17.0, *)
public enum PlanComparisonValue {
    case present
    case missing
    case number(n: Int)
    case unlimited
}

@available(iOS 17.0, *)
public struct FeatureEntry {
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
@resultBuilder
public struct FeatureEntryBuilder {
    public static func buildBlock(_ components: FeatureEntry...) -> [FeatureEntry] {
        components
    }
}

@available(iOS 17.0, *)
public struct PlanComparisonItem: View {
    let value: PlanComparisonValue
    
    public init(_ value: PlanComparisonValue) {
        self.value = value
    }

    public var body: some View {
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
public struct ListedFeatures<HeaderContent: View, HeadlineContent: View, TrialContent: View>: View {
    let primaryBackgroundColor: Color
    let secondaryBackgroundColor: Color
    let features: [FeatureEntry]
    let headerContent: HeaderContent
    let headlineContent: HeadlineContent
    let otherContent: TrialContent

    let screenWidth = UIScreen.main.bounds.width
    
    public init(
        primaryBackgroundColor: Color = Color(UIColor.systemBackground),
        secondaryBackgroundColor: Color = Color(UIColor.systemFill),
        @FeatureEntryBuilder features: () -> [FeatureEntry],
        @ViewBuilder headerContent: () -> HeaderContent,
        @ViewBuilder headlineContent: () -> HeadlineContent = { EmptyView() },
        @ViewBuilder trialContent: () -> TrialContent = { EmptyView() }
    ) {
        self.primaryBackgroundColor = primaryBackgroundColor
        self.secondaryBackgroundColor = secondaryBackgroundColor
        self.features = features()
        self.headerContent = headerContent()
        self.headlineContent = headlineContent()
        self.otherContent = trialContent()
    }
    
    public init(
        primaryBackgroundColor: Color = Color(UIColor.systemBackground),
        secondaryBackgroundColor: Color = Color(UIColor.systemFill),
        features: [FeatureEntry],
        @ViewBuilder headerContent: () -> HeaderContent,
        @ViewBuilder headlineContent: () -> HeadlineContent = { EmptyView() },
        @ViewBuilder trialContent: () -> TrialContent = { EmptyView() }
    ) {
        self.primaryBackgroundColor = primaryBackgroundColor
        self.secondaryBackgroundColor = secondaryBackgroundColor
        self.features = features
        self.headerContent = headerContent()
        self.headlineContent = headlineContent()
        self.otherContent = trialContent()
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
                // Headline
                headlineContent
                
                // Features
                VStack(spacing: 4) {
                    ForEach(Array(features.enumerated()), id: \.offset) { (offset, element) in
                        let feature = element
                        
                        HStack(alignment: .top, spacing: 20) {
                            Image(systemName: feature.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(AppScaffoldUI.accent)
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
                otherContent
                
                Spacer()

                Rectangle()
                    .frame(height: 150)
                    .foregroundStyle(.clear)
            }
            .frame(width: screenWidth)
            .frame(minHeight: UIScreen.height - 300)
            .background(primaryBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.15), radius: 4)
            .offset(y: -50)
        }
        .coordinateSpace(name: CoordinateSpaces.scrollView)
        .edgesIgnoringSafeArea(.all)
        .background(secondaryBackgroundColor)
    }
}

@available(iOS 17.0, *)
public struct TableComparisonFeatures<HeaderContent: View, HeadlineContent: View, TrialContent: View>: View {
    let iconSize = 24.0
    
    let primaryBackgroundColor: Color
    let secondaryBackgroundColor: Color
    let features: [FeatureEntry]
    let headerContent: HeaderContent
    let headlineContent: HeadlineContent
    let trialContent: TrialContent
    let premiumEntitlementName: String
    
    public init(
        primaryBackgroundColor: Color = Color(UIColor.systemBackground),
        secondaryBackgroundColor: Color = Color(UIColor.systemFill),
        @FeatureEntryBuilder features: () -> [FeatureEntry],
        paidPackageName: String? = "Premium",
        @ViewBuilder headerContent: () -> HeaderContent,
        @ViewBuilder headlineContent: () -> HeadlineContent = { EmptyView() },
        @ViewBuilder trialContent: () -> TrialContent = { EmptyView() }
    ) {
        self.primaryBackgroundColor = primaryBackgroundColor
        self.secondaryBackgroundColor = secondaryBackgroundColor
        self.features = features()
        self.headerContent = headerContent()
        self.headlineContent = headlineContent()
        self.trialContent = trialContent()
        self.premiumEntitlementName = paidPackageName ?? "Premium"
    }
    
    public init(
        primaryBackgroundColor: Color = Color(UIColor.systemBackground),
        secondaryBackgroundColor: Color = Color(UIColor.systemFill),
        features: [FeatureEntry],
        paidPackageName: String? = nil,
        @ViewBuilder headerContent: () -> HeaderContent,
        @ViewBuilder headlineContent: () -> HeadlineContent = { EmptyView() },
        @ViewBuilder trialContent: () -> TrialContent = { EmptyView() }
    ) {
        self.primaryBackgroundColor = primaryBackgroundColor
        self.secondaryBackgroundColor = secondaryBackgroundColor
        self.features = features
        self.headerContent = headerContent()
        self.headlineContent = headlineContent()
        self.trialContent = trialContent()
        self.premiumEntitlementName = paidPackageName ?? "Premium"
    }
    
    public var body: some View {
        ScrollView {
            header
            headlineContent
            
            HStack {
                //Feature column
                VStack {
                    Rectangle()
                        .fill(.clear)
                        .frame(height: iconSize)
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        HStack {
                            Image (systemName: feature.icon)
                            Text(feature.name)
                            Spacer()
                        }
                        .frame(height: iconSize)
                    }
                }
                
                //Free column
                VStack {
                    Text("Free")
                        .font(.system(size: 17))
                        .frame(height: iconSize)
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        presenceIndicator(feature.basic)
                    }
                }
                
                //Premium column
                VStack {
                    Text(premiumEntitlementName)
                        .font(.system(size: 19))
                        .fontWeight(.semibold)
                        .frame(height: iconSize)
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        presenceIndicator(feature.pro)
                    }
                }
                .padding(12)
                .background(.green.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .ignoresSafeArea()
    }
    
    var header: some View {
        Image(.headermaskIphone)
            .resizable()
            .scaledToFit()
            .opacity(0.3)
            .overlay {
                headerContent
                    .mask{
                        Image(.headermaskIphone)
                            .resizable()
                            .scaledToFit()
                    }
            }
    }
    
    func presenceIndicator(_ featurePresence: PlanComparisonValue) -> some View {
        return ZStack {
            switch featurePresence {
            case .missing:
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(.secondary)
            case .present:
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
//                    .foregroundStyle(AppScaffoldUI.accent)
                    .foregroundStyle(.green)
                
            case .number(let n):
                Text("\(n)")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: iconSize, height: iconSize)
            case .unlimited:
                Image(systemName: "infinity")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .fontWeight(.semibold)
//                    .foregroundStyle(AppScaffoldUI.accent)
                    .foregroundStyle(.green)
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    TableComparisonFeatures {
        FeatureEntry(icon: "trash", name: "Unlimited Dummy 1", description: "Dummy 1 description", basic: .missing, pro: .present)
        
        FeatureEntry(icon: "drop", name: "Amazing Dummy 2", description: "Dummy 2 description", basic: .missing, pro: .present)
        
        FeatureEntry(icon: "drop", name: "Dummy 2", description: "Dummy 2 description", basic: .number(n: 10), pro: .unlimited)
        
        FeatureEntry(icon: "drop", name: "Amazing Dummy 2", description: "Dummy 2 description", basic: .missing, pro: .present)
        
        FeatureEntry(icon: "drop", name: "Amazing Dummy 2", description: "Dummy 2 description", basic: .missing, pro: .present)
    } headerContent: {
        Rectangle()
    } headlineContent: {
        VStack {
            Text("Unlock All features")
            Text("With My App Premium")
        }
        .font(.title2)
        .fontWeight(.semibold)
    }
    .accentColor(Color.yellow)
}

