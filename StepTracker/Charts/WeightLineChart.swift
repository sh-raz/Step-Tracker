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
                    AreaMark(
                        x: .value("Date", weight.date, unit: .day),
                        y: .value("Weights", weight.value)
                    )
                    .foregroundStyle(Gradient(colors: [.blue.opacity(0.5), .clear]))
                    
                    LineMark(
                        x: .value("Date", weight.date, unit: .day),
                        y: .value("Weights", weight.value)
                    )
                }
            }
            .frame(height: 150)
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
