//
//  ChartContainer.swift
//  StepTracker
//
//  Created by Shilan on 21/09/2026.
//

import SwiftUI

struct ChartContainer<Content: View>: View {
    
    let chartType: ChartType
    @ViewBuilder var content: () -> Content
    
    
    var body: some View {
        VStack(alignment: .leading) {
            if chartType.isNav {
                navigationLinkView
                content()
            }else{
                titleView
                    .padding(.bottom, 12)
                content()
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))
        }
    }
    
    
    var navigationLinkView: some View {
        NavigationLink(value: chartType.context) {
            HStack {
                titleView
                Spacer()
                Image(systemName: "chevron.forward")
            }
        }
        .padding(.bottom, 12)
        .foregroundStyle(Color.secondary)
        .accessibilityHint("Tap to show data in list")
    }
    
    
    var titleView: some View {
        VStack(alignment: .leading){
            Label(chartType.title, systemImage: chartType.imageName)
                .font(.title3.bold())
                .foregroundStyle(chartType.context == .steps ? Color.pink : Color.indigo)
            Text(chartType.subtitle)
                .font(.caption)
                .foregroundStyle(Color.secondary)
        }
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(chartType.accesibilityLabel)
        .accessibilityElement(children: .ignore)
    }
}

#Preview {
    ChartContainer(chartType: .StepBar(average: 15000)) {
        Text("Steps")
    }
}
