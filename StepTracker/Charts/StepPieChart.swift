//
//  StepPieChart.swift
//  StepTracker
//
//  Created by Shilan on 11/09/2026.
//

import SwiftUI
import Charts

struct StepPieChart: View {
    
    var pieChartData: [WeekdayDataType]
    @State private var selectedWeekdayValue: Double? = 0 //*
    
    var selectedWeekday: WeekdayDataType? {
        guard let selectedWeekdayValue else { return nil }
        var total = 0.0
        return pieChartData.first{
            total += $0.value
            return selectedWeekdayValue <= total
        }
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Label("Averages", systemImage: "calendar")
                    .font(.title3.bold())
                    .foregroundStyle(Color.pink)
                Text("Last 28 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 12)
            
            Chart{
                ForEach(pieChartData) { weekdayData in
                    SectorMark(angle: .value("Average for day", weekdayData.value),
                               innerRadius: .ratio(0.618),
                               outerRadius: (selectedWeekday?.date.weekdayInt == weekdayData.date.weekdayInt ? 140 : 110),
                               angularInset: 1.2)
                    .foregroundStyle(.pink.gradient)
                    .cornerRadius(5)
                    .opacity(selectedWeekday?.date.weekdayInt == weekdayData.date.weekdayInt ? 1.0 : 0.3)
                }
            }
            .frame(height: 240)
            .chartAngleSelection(value: $selectedWeekdayValue.animation(.easeInOut))
            .chartBackground { chartProxy in
                GeometryReader { GeometryProxy in
                    if let plotFrame = chartProxy.plotFrame  {
                        let frame = GeometryProxy[plotFrame]
                        if let selectedWeekday {
                            VStack{
                                Text(selectedWeekday.date, format: .dateTime.weekday(.wide))
                                    .font(.title3.bold())
                                    .contentTransition(.identity)
                                    
                                Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText())
                            }
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
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
    StepPieChart(pieChartData: ChartMath.averagePerWeek(for: HealthMetric.dataForPreview))
}
