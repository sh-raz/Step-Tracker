//
//  ChartType.swift
//  StepTracker
//
//  Created by Shilan on 23/09/2026.
//

import Foundation

enum ChartType {
    case StepBar(average: Int)
    case StepPie
    case WeightLine(average: Double)
    case WeightDiffBar
    
    var isNav: Bool {
        switch self {
        case .StepBar, .WeightLine:
            return true
        case .StepPie, .WeightDiffBar:
            return false
        }
    }
    var context: HealthMetricContext {
        switch self {
        case .StepBar, .StepPie:
            return .steps
        case .WeightLine, .WeightDiffBar:
            return .weight
        }
    }
    
    var title: String {
        switch self {
        case .StepBar(_):
            "Steps"
        case .StepPie:
            "Averages"
        case .WeightLine(_):
            "Weights"
        case .WeightDiffBar:
            "Average Weight Change"
        }
    }
    
    var imageName: String {
        switch self {
        case .StepBar(_):
            "figure.walk"
        case .StepPie:
            "calendar"
        case .WeightLine(_):
            "figure"
        case .WeightDiffBar:
            "figure"
        }
    }
    
    var subtitle: String {
        switch self {
        case .StepBar(let average):
            "Avg: \(average.formatted()) Steps"
        case .StepPie:
            "Last 28 days"
        case .WeightLine(let average):
            "Avg: \(average.formatted(.number.precision(.fractionLength(1)))) pounds"
        case .WeightDiffBar:
            "Per Weekday (Last 28 Days)"
        }
    }
    
    var accesibilityLabel: String {
        switch self {
        case .StepBar(let average):
            "Bar chart, step count, last 28 days, average steps per day: \(average) steps"
        case .StepPie:
            "Pie Chart, average steps per weekday"
        case .WeightLine(let average):
            "Line Chart, weight, avgerage weight: \(average.formatted(.number.precision(.fractionLength(1)))) pounds, goal weight: 155 pounds"
        case .WeightDiffBar:
            "Bar Chart, average weight difference per weekday"
        }
    }
}
