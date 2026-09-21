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
    @State private var selectedWeekdayValue: Double? = 0
    @State private var selectedDay: Date?
    
    var selectedWeekday: WeekdayDataType? {
        guard let selectedWeekdayValue else { return nil }
        var total = 0.0
        return pieChartData.first{
            total += $0.value
            return selectedWeekdayValue <= total
        }
    }
    
    var body: some View {
        ChartContainer(title: "Averages", imageName: "calendar", description: "Last 28 days", context: .steps, isNav: false) {
            
            if pieChartData.isEmpty {
                EmptyChartView(systemImageName: "chart.pie", title: "No Data", description: "There is no step count data from the Health App.")
                    .frame(height: 200)
            }else{
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
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: selectedWeekday) { oldValue, newValue in
            guard let oldValue, let newValue else { return }
            if oldValue.date.weekdayInt != newValue.date.weekdayInt {
                selectedDay = newValue.date
            }
        }
    }
}

#Preview {
    StepPieChart(pieChartData: ChartMath.averagePerWeek(for: HealthMetric.dataForPreview))
}
