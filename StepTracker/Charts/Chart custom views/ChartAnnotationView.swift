//
//  ChartAnnotationView.swift
//  StepTracker
//
//  Created by Shilan on 21/09/2026.
//

import SwiftUI
import Charts

struct ChartAnnotationView: ChartContent {
    var selectedData: ChartDataModel
    var context: HealthMetricContext
    
    var body: some ChartContent {
        RuleMark(x: .value("Selected Health Metric", selectedData.date, unit: .day))
            .foregroundStyle(Color.secondary.opacity(0.3))
            .offset(y: -10)
            .annotation(position: .top,
                        spacing: 0,
                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                annotationView
            }
    }
    
    
    var annotationView: some View {
        VStack{
            Text(selectedData.date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(Color.secondary)
            Text(selectedData.value, format: .number.precision(context == .steps ? .fractionLength(0) : .fractionLength(2)))
                .foregroundStyle(context == .steps ? Color.pink : (selectedData.value >= 0 ? Color.indigo : Color.mint))
                .fontWeight(.heavy)
        }
        .padding(15)
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(Color(.secondarySystemBackground))
            .shadow(color: Color.secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}
