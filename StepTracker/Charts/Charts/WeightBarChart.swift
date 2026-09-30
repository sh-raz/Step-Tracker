//
//  WeightBarChart.swift
//  StepTracker
//
//  Created by Shilan on 15/09/2026.
//

import SwiftUI
import Charts

struct WeightBarChart: View {
    @State private var selectedDate: Date?
    @State private var selectedDay: Date?
    
    var chartData: [ChartDataModel]
    
    var selectedData: ChartDataModel? {
        ChartHelper.selectedData(from: chartData, in: selectedDate)
    }
    
    var body: some View {
 
        ChartContainer(chartType: .WeightDiffBar) {
                Chart {
                    if let selectedData {
                        ChartAnnotationView(selectedData: selectedData, context: .weight)
                    }
                    ForEach(chartData) { averageData in
                        BarMark(
                            x: .value("Date", averageData.date, unit: .day),
                            y: .value("Weights", averageData.value)
                        )
                        .foregroundStyle(averageData.value >= 0 ? Color.indigo.gradient : Color.mint.gradient)
                        .accessibilityLabel(averageData.date.weekdayTitle)
                        .accessibilityValue("\(averageData.value.formatted(.number.precision(.fractionLength(1)).sign(strategy: .always()))) pounds")
                    }
                }
                .frame(height: 240)
                .chartYScale(domain: .automatic(includesZero: true))
                
                .chartXAxis {
                    AxisMarks(values: AxisMarkValues.stride(by: .day)) {
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated),centered: true)
                    }
                }
                .chartYAxis {
                    AxisMarks{
                        AxisGridLine()
                            .foregroundStyle(Color.secondary.opacity(0.3))
                        AxisValueLabel()
                    }
                }
                .chartXSelection(value: $selectedDate)
            }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: selectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
        .overlay {
            if chartData.isEmpty {
                EmptyChartView(systemImageName: "chart.bar", title: "No Data", description: "There is no weight data from the Health App.")
                    .frame(height: 200)
            }
        }
        .accessibilityLabel(ChartType.WeightDiffBar.accesibilityLabel)
    }
}

#Preview {
    WeightBarChart(chartData: ChartHelper.averageDailyWeightDiffs(for: MockData.weights))
}

