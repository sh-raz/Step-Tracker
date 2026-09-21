//
//  ChartContainer.swift
//  StepTracker
//
//  Created by Shilan on 21/09/2026.
//

import SwiftUI

struct ChartContainerConfiguration {
    var title: String
    var imageName: String
    var description: String
    var context: HealthMetricContext
    var isNav: Bool
}

struct ChartContainer<Content: View>: View {
    var config: ChartContainerConfiguration
    @ViewBuilder var content: () -> Content
    
    
    var body: some View {
        VStack(alignment: .leading) {
            if config.isNav {
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
        NavigationLink(value: config.context) {
            HStack {
                titleView
                Spacer()
                Image(systemName: "chevron.forward")
            }
        }
        .padding(.bottom, 12)
        .foregroundStyle(Color.secondary)
    }
    
    
    var titleView: some View {
        VStack(alignment: .leading){
            Label(config.title, systemImage: config.imageName)
                .font(.title3.bold())
                .foregroundStyle(config.context == .steps ? Color.pink : Color.indigo)
            Text(config.description)
                .font(.caption)
                .foregroundStyle(Color.secondary)
        }
    }
}

#Preview {
    ChartContainer(config: ChartContainerConfiguration(title: "Steps", imageName: "figure.walk", description: "Average 12000 steps", context: .steps, isNav: false)) {
        Text("Steps")
    }
}
