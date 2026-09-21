//
//  StepBarChart.swift
//  StepTracker
//
//  Created by Shilan on 10/09/2026.
//

import SwiftUI
import Charts

struct StepBarChart: View {
    
    var chartData: [ChartDataModel]
    @State private var selectedDate: Date?
    @State private var selectedDay: Date?
    
    var selectedData: ChartDataModel? {
        ChartHelper.selectedData(from: chartData, in: selectedDate)
    }
    
    var avgSteps: Double {
        guard !chartData.isEmpty else {return 0}
        let total = chartData.reduce(0) { $0 + $1.value }
        return total / Double(chartData.count)
    }
    
    var body: some View {
        ChartContainer(title: "Steps", imageName: "figure.walk", description: "Avg: \(Int(avgSteps)) Steps", context: .steps, isNav: true) {
            if chartData.isEmpty {
                EmptyChartView(systemImageName: "chart.bar", title: "No Data", description: "There is no step count data from the Health App.")
                    .frame(height: 150)
            }else{
                Chart {
                    if let selectedData {
                        RuleMark(x: .value("Selected Health Metric", selectedData.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(position: .top,
                                        spacing: 0,
                                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                ChartAnnotationView(selectedData: selectedData, context: .steps)
                            }
                    }
                    RuleMark(y: .value("Average", avgSteps))
                        .lineStyle(.init(lineWidth: 0.6, dash: [5]))
                        .foregroundStyle(Color.secondary)
                    
                    ForEach(chartData) { step in
                        BarMark(
                            x: .value("Date", step.date, unit: .day),
                            y: .value("Steps", step.value)
                        )
                        .foregroundStyle(Color.pink.gradient)
                        .opacity(selectedDate == nil || selectedData?.date == step.date ? 1.0 : 0.3)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $selectedDate.animation(.easeInOut))
                .chartXAxis {
                    AxisMarks{
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                    }
                }
                .chartYAxis{
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(Color.secondary.opacity(0.3))
                        AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: selectedDate) { oldValue, newValue in
            guard let old = oldValue, let new = newValue else { return }
            if !Calendar.current.isDate(old, inSameDayAs: new){
                selectedDay = new
            }
        }
    }
}

#Preview {
    StepBarChart(chartData: ChartHelper.converToChartData(data: MockData.steps))
}
