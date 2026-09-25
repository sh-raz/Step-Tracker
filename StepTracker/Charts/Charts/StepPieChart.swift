//
//  StepPieChart.swift
//  StepTracker
//
//  Created by Shilan on 11/09/2026.
//

import SwiftUI
import Charts

struct StepPieChart: View {
    
    var chartData: [ChartDataModel]
    @State private var selectedWeekdayValue: Double? = 0
    @State private var selectedDay: Date?
    @State private var lastSelectedValue: Double = 0
    
    var selectedWeekday: ChartDataModel? {
        var total = 0.0
        return chartData.first{
            total += $0.value
            return lastSelectedValue <= total
        }
    }
    
    var body: some View {
        ChartContainer(chartType: .StepPie) {
            Chart{
                ForEach(chartData) { weekdayData in
                    SectorMark(angle: .value("Average for day", weekdayData.value),
                               innerRadius: .ratio(0.618),
                               outerRadius: (selectedWeekday?.date.weekdayInt == weekdayData.date.weekdayInt ? 140 : 110),
                               angularInset: 1.2)
                    .foregroundStyle(.pink.gradient)
                    .cornerRadius(5)
                    .opacity(selectedWeekday?.date.weekdayInt == weekdayData.date.weekdayInt ? 1.0 : 0.3)
                    .accessibilityLabel(weekdayData.date.weekdayTitle)
                    .accessibilityValue("\(Int(weekdayData.value)) steps")
                }
            }
            .frame(height: 240)
            .chartAngleSelection(value: $selectedWeekdayValue.animation(.easeInOut))
            .onChange(of: selectedWeekdayValue) { oldValue, newValue in
                withAnimation(.easeInOut)
                {
                    guard let newValue else {
                        lastSelectedValue = oldValue ?? 0
                        return
                    }
                    lastSelectedValue = newValue
                }
            }
            .chartBackground { chartProxy in
                GeometryReader { GeometryProxy in
                    if let plotFrame = chartProxy.plotFrame  {
                        let frame = GeometryProxy[plotFrame]
                        if let selectedWeekday {
                            VStack{
                                Text(selectedWeekday.date, format: .dateTime.weekday(.wide))
                                    .font(.title3.bold())
                                    .animation(.none)
                                Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText())
                            }
                            .position(x: frame.midX, y: frame.midY)
                            .accessibilityHidden(true)
                        }
                    }
                }
            }
            .overlay {
                if chartData.isEmpty {
                    EmptyChartView(systemImageName: "chart.pie", title: "No Data", description: "There is no step count data from the Health App.")
                        .frame(height: 200)
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
        .accessibilityLabel(ChartType.StepPie.accesibilityLabel)
    }
}

#Preview {
    StepPieChart(chartData: ChartHelper.averagePerWeek(for: MockData.steps))
}
