//
//  ChartHelper.swift
//  StepTracker
//
//  Created by Shilan on 21/09/2026.
//

import Foundation
import Algorithms

struct ChartHelper {
    
    /// Converts an array of ``HealthMetric`` to an array of ``ChartDataModel``.
    /// - Parameter data: The source metric.
    /// - Returns: An array of ``ChartDataModel``.
   static func converToChartData(data: [HealthMetric]) -> [ChartDataModel] {
       return data.map {
            .init(date: $0.date, value: $0.value)
        }
    }
    
    /// Returns the first element of the  given array that occures on the same calendar day as the given date.
    /// - Parameters:
    ///   - chartData: An array of ``HealthMetric`` to search.
    ///   - date: The target date, if `nil` the function will return `nil`.
    /// - Returns: The first `ChartDataModel` whose `date` is in the same day as`date`, or `nil` if none match.
    static func selectedData(from chartData: [ChartDataModel], in date: Date?) -> ChartDataModel? {
        guard let date else {return nil}
        return chartData.first {
            Calendar.current.isDate(date, inSameDayAs: $0.date)
        }
    }
  
    
    /// Calculates the average of steps for each weekday across the input.
    /// - Parameter metrics: An array of  ``HealthMetric``
    /// - Returns: One `ChartDataModel` per weekday, where `date` is taken from the first sample for that weekday and `value` is the average steps for that weekday.
    static func averageStepsPerWeekday(for metrics: [HealthMetric]) -> [ChartDataModel] {
         var stepPerWeekday: [ChartDataModel] = []
        let sortedMetrics = metrics.sorted(using: KeyPathComparator(\.date.weekdayInt))
         let weekdayArrays = sortedMetrics.chunked{ $0.date.weekdayInt == $1.date.weekdayInt }
                 
         for array in weekdayArrays {
             guard let firstElement = array.first else { continue }
             let total = array.reduce(0) { $0 + $1.value }
             let avgPerWeekday = total / Double(array.count)
             stepPerWeekday.append(.init(date: firstElement.date, value: avgPerWeekday))
         }
         return stepPerWeekday
     }
     
    
    /// Calculates the weight changes for each day compared to its previous day and returnes the average of changes per weekday
    /// - Parameter weights: An array of weight samples 
    /// - Returns: An array of ``ChartDataModel``, where `date` is taken from the first sample of a specific weekday (Ex. Monday) and the `value` is the average of (current day value − previous day value) for that weekday.
     static func averageDailyWeightDiffs(for weights: [HealthMetric]) -> [ChartDataModel] {
         var diffArray: [(date: Date, diff: Double)] = []
         
         guard weights.count > 1 else { return [] }
         for i in 1..<weights.count {
                 let date = weights[i].date
                 let diff = weights[i].value - weights[i-1].value
                 diffArray.append((date: date, diff: diff))
         }
         let sortedDiffs = diffArray.sorted(using: KeyPathComparator(\.date.weekdayInt))
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
