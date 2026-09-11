//
//  ChartMath.swift
//  StepTracker
//
//  Created by Shilan on 10/09/2026.
//

import Foundation
import Algorithms

struct ChartMath {
    
   static func averagePerWeek(for metrics: [HealthMetric]) -> [WeekdayDataType] {
        var stepPerWeekday: [WeekdayDataType] = []
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
    
}
