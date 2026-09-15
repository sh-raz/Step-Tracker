//
//  WeightBarChart.swift
//  StepTracker
//
//  Created by Shilan on 15/09/2026.
//

import SwiftUI
import Charts

struct WeightBarChart: View {
    @State private var selectedWeekday: Date?
    
    var chartData: [WeekdayDataType]
    
    var selectedData: WeekdayDataType? {
        guard let selectedWeekday else {return nil}
        return chartData.first {
            $0.date.weekdayInt == selectedWeekday.weekdayInt
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading){
                    Label("Average Weight Change", systemImage: "figure")
                        .font(.title3.bold())
                        .foregroundStyle(Color.indigo)
                    Text("Per Weekday (Last 28 Days)")
                        .font(.caption)
                }
                Spacer()
            }
            .padding(.bottom, 12)
            .foregroundStyle(Color.secondary)
            
            Chart {
                if let selectedData {
                    RuleMark(x: .value("Selected Weekday", selectedData.date, unit: .day))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                        .annotation(position: .top,
                                    spacing: 0,
                                    overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            annotationView
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
            .chartXSelection(value: $selectedWeekday)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))
        }
    }
    
    var annotationView: some View {
        VStack{
            Text(selectedData?.date ?? .now, format: .dateTime.weekday(.wide))
                .font(.footnote.bold())
                .foregroundStyle(Color.secondary)
            Text(selectedData?.value ?? 0, format: .number.precision(.fractionLength(2)).sign(strategy: .always()))
                .foregroundStyle((selectedData?.value ?? 0) >= 0 ? Color.indigo : Color.mint)
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
    WeightBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: MockData.weights))
}

