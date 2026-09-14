//
//  WeightLineChart.swift
//  StepTracker
//
//  Created by Shilan on 11/09/2026.
//

import SwiftUI
import Charts

struct WeightLineChart: View {
    
    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]
    var minWeight: Double {
        return chartData.min{ $0.value < $1.value }?.value ?? 0
    }
    
    
    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack {
                    VStack(alignment: .leading){
                        Label("Weights", systemImage: "figure")
                            .font(.title3.bold())
                            .foregroundStyle(Color.indigo)
                        Text("Avg:  pounds")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: "chevron.forward")
                }
            }
            .padding(.bottom, 12)
            .foregroundStyle(Color.secondary)
            
            Chart {
                ForEach(chartData) { weight in
                    RuleMark(y: .value("Goal", 155))
                        .foregroundStyle(.mint)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                    
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
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))
        }
    }
}


#Preview {
    WeightLineChart(selectedStat: .weight, chartData: MockData.weights)
}
