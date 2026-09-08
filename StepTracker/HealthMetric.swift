//
//  HealthMetric.swift
//  StepTracker
//
//  Created by Shilan on 08/09/2026.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
