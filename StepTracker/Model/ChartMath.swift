//
//  ChartMath.swift
//  StepTracker
//
//  Created by Shilan on 10/09/2026.
//

import Foundation
import Algorithms

struct ChartMath {
    
   static func averagePerWeek(for metrics: [HealthMetric]) -> [ChartDataModel] {
        var stepPerWeekday: [ChartDataModel] = []
        let sortedMetrics = metrics.sorted{ $0.date.weekdayInt < $1.date.weekdayInt }
        let weekdayArrays = sortedMetrics.chunked{ $0.date.weekdayInt == $1.date.weekdayInt }
                
        for array in weekdayArrays {
            guard let firstElement = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgPerWeekday = total / Double(array.count)
            stepPerWeekday.append(.init(date: firstElement.date, value: avgPerWeekday))
        }
        return stepPerWeekday
    }
    
    
    static func averageDailyWeightDiffs(for weights: [HealthMetric]) -> [ChartDataModel] {
        var diffArray: [(date: Date, diff: Double)] = []
        
        guard weights.count > 1 else { return [] }
        for i in 1..<weights.count {
                let date = weights[i].date
                let diff = weights[i].value - weights[i-1].value
                diffArray.append((date: date, diff: diff))
        }
        let sortedDiffs = diffArray.sorted{ $0.date.weekdayInt < $1.date.weekdayInt }
        let diffArrays = sortedDiffs.chunked { $0.date.weekdayInt == $1.date.weekdayInt}
        var weekdayChartData: [ChartDataModel] = []
       
        for array in diffArrays {
            guard let firstElement = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.diff }
            let average = total / Double(array.count)
            
            weekdayChartData.append(.init(date: firstElement.date, value: average))
        }
        return weekdayChartData
    }
 
    
}
