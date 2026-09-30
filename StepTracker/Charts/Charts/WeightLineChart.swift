//
//  WeightLineChart.swift
//  StepTracker
//
//  Created by Shilan on 11/09/2026.
//

import SwiftUI
import Charts

struct WeightLineChart: View {
    @State private var selectedDate: Date?
    @State private var selectedDay: Date?
    
    
    var chartData: [ChartDataModel]
    var minWeight: Double {
        return chartData.min{ $0.value < $1.value }?.value ?? 0
    }
    
    var selectedData: ChartDataModel? {
        ChartHelper.selectedData(from: chartData, in: selectedDate)
    }
    
    var avgWeight: Double {
        chartData.map{$0.value}.average
    }
    
    
    
    var body: some View {
        ChartContainer(chartType: .WeightLine(average: avgWeight)) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(selectedData: selectedData, context: .weight)
                }
                RuleMark(y: .value("Goal", 155))
                    .foregroundStyle(.mint)
                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                    .accessibilityHidden(true)
                
                ForEach(chartData) { weight in
                    Plot{
                        AreaMark(
                            x: .value("Date", weight.date, unit: .day),
                            yStart: .value("Weight", weight.value),
                            yEnd: .value("Min value", minWeight)
                        )
                        .foregroundStyle(Gradient(colors: [.indigo.opacity(0.5), .clear]))
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Date", weight.date, unit: .day),
                            y: .value("Weights", weight.value)
                        )
                        .foregroundStyle(.indigo)
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                    }
                    .accessibilityLabel(weight.date.accesibilityDate)
                    .accessibilityValue(weight.value.formatted(.number.precision(.fractionLength(1))))
                }
            }
            .frame(height: 150)
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis {
                AxisMarks{
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
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
            .overlay {
                if chartData.isEmpty {
                    EmptyChartView(systemImageName: "chart.line.downtrend.xyaxis", title: "No Data", description: "There is no weight data from the Health App.")
                        .frame(height: 150)
                }
            }
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            guard let old = oldValue, let new = newValue else { return }
            if !Calendar.current.isDate(old, inSameDayAs: new){
                selectedDay = new
            }
        }
        .accessibilityLabel(ChartType.WeightLine(average: avgWeight).accesibilityLabel)
    }
}


#Preview {
    WeightLineChart(chartData: ChartHelper.converToChartData(data: MockData.weights))
}
