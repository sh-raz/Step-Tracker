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
        ChartContainer(title: "Average Weight Change", imageName: "figure", description: "Per Weekday (Last 28 Days)", context: .weight, isNav: false) {
            
            if chartData.isEmpty {
                EmptyChartView(systemImageName: "chart.bar", title: "No Data", description: "There is no weight data from the Health App.")
                    .frame(height: 200)
            }else{
                Chart {
                    if let selectedData {
                        RuleMark(x: .value("Selected Weekday", selectedData.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .annotation(position: .top,
                                        spacing: 0,
                                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                ChartAnnotationView(selectedData: selectedData, context: .weight)
                            }
                    }
                    ForEach(chartData) { averageData in
                        BarMark(
                            x: .value("Date", averageData.date, unit: .day),
                            y: .value("Weights", averageData.value)
                        )
                        .foregroundStyle(averageData.value >= 0 ? Color.indigo.gradient : Color.mint.gradient)
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
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: selectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
    }
}

#Preview {
    WeightBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: MockData.weights))
}

