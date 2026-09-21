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
    
    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]
    var minWeight: Double {
        return chartData.min{ $0.value < $1.value }?.value ?? 0
    }
    
    var selectedMetric: HealthMetric? {
        guard let selectedDate else {return nil}
        return chartData.first {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        }
    }
    
    
    var body: some View {
        ChartContainer(title: "Weights", imageName: "figure", description: "Avg:  pounds", context: .weight, isNav: true) {
        
            if chartData.isEmpty {
                EmptyChartView(systemImageName: "chart.line.downtrend.xyaxis", title: "No Data", description: "There is no weight data from the Health App.")
                    .frame(height: 150)
            }else{
                Chart {
                    if let selectedMetric {
                        RuleMark(x: .value("Selected Health Metric", selectedMetric.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(position: .top,
                                        spacing: 0,
                                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                annotationView
                            }
                    }
                    RuleMark(y: .value("Goal", 155))
                        .foregroundStyle(.mint)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                    
                    ForEach(chartData) { weight in
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
            }
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            guard let old = oldValue, let new = newValue else { return }
            if !Calendar.current.isDate(old, inSameDayAs: new){
                selectedDay = new
            }
        }
    }
    
    
    var annotationView: some View {
        VStack{
            Text(selectedMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(Color.secondary)
            Text(selectedMetric?.value ?? 0, format: .number.precision(.fractionLength(1)))
                .foregroundStyle(Color.indigo)
                .fontWeight(.heavy)
        }
        .padding(15)
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(Color(.secondarySystemBackground))
            .shadow(color: Color.secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}


#Preview {
    WeightLineChart(selectedStat: .weight, chartData: MockData.weights)
}
