//
//  WeekdayDataType.swift
//  StepTracker
//
//  Created by Shilan on 10/09/2026.
//

import Foundation


struct ChartDataModel: Identifiable, Equatable{
    let id = UUID()
    let date: Date
    let value: Double
}
