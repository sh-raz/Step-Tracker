//
//  StepBarChart.swift
//  StepTracker
//
//  Created by Shilan on 10/09/2026.
//

import SwiftUI
import Charts

struct StepBarChart: View {
    
    var chartData: [HealthMetric]
    var selectedStat: HealthMetricContext
    @State private var selectedDate: Date?

    
    var avgSteps: Double {
        guard !chartData.isEmpty else {return 0}
        let total = chartData.reduce(0) { $0 + $1.value }
        return total / Double(chartData.count)
    }
    
    var selectedHealthMetric: HealthMetric? {
        guard let selectedDate else {return nil}
        return chartData.first {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        }
    }
    
    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack {
                    VStack(alignment: .leading){
                        Label("Steps", systemImage: "figure.walk")
                            .font(.title3.bold())
                            .foregroundStyle(Color.pink)
                        Text("Avg: \(Int(avgSteps)) Steps")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: "chevron.forward")
                }
            }
            .padding(.bottom, 12)
            .foregroundStyle(Color.secondary)
            
            Chart {
                if let selectedHealthMetric {
                    RuleMark(x: .value("Selected Health Metric", selectedHealthMetric.date, unit: .day))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                        .offset(y: -10)
                        .annotation(position: .top,
                                    spacing: 0,
                                    overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            annotationView                                   }
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
                    .opacity(selectedDate == nil || selectedHealthMetric?.date == step.date ? 1.0 : 0.3)
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
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))
        }
    }
    
    var annotationView: some View {
        VStack{
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(Color.secondary)
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(0)))
                .foregroundStyle(Color.pink)
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
    StepBarChart(chartData: HealthMetric.dataForPreview, selectedStat: .steps)
}
