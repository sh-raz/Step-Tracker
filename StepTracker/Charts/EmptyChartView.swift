//
//  EmptyChartView.swift
//  StepTracker
//
//  Created by Shilan on 18/09/2026.
//

import SwiftUI

struct EmptyChartView: View {
    let systemImageName: String
    let title: String
    let description: String
    
    var body: some View {
        ContentUnavailableView {
            Image(systemName: systemImageName)
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.bottom, 8)
            Text(title)
                .font(.callout.bold())
            Text(description)
                .font(.footnote)
        }
        .foregroundStyle(.secondary)
        .offset(y: -10)
    }
}

#Preview {
    EmptyChartView(systemImageName: "chart.bar", title: "No Data", description: "There is no data to show.")
}
