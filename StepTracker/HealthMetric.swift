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
    
    static var dataForPreview: [HealthMetric] {
        var steps: [HealthMetric] = []
        for i in 0..<28 {
            let step = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                    value: .random(in: 4000...15000))
            steps.append(step)
        }
        return steps
    }
}
