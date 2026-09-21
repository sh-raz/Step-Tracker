//
//  ChartHelper.swift
//  StepTracker
//
//  Created by Shilan on 21/09/2026.
//

import Foundation

struct ChartHelper {
   static func converToChartData(data: [HealthMetric]) -> [ChartDataModel] {
       return data.map {
            .init(date: $0.date, value: $0.value)
        }
    }
    
    static func selectedData(from chartData: [ChartDataModel], in date: Date?) -> ChartDataModel? {
        guard let date else {return nil}
        return chartData.first {
            Calendar.current.isDate(date, inSameDayAs: $0.date)
        }
    }
}
