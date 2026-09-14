//
//  MockData.swift
//  StepTracker
//
//  Created by Shilan on 11/09/2026.
//

import Foundation

struct MockData {
    
    static var steps: [HealthMetric] {
        var steps: [HealthMetric] = []
        for i in 0..<28 {
            let step = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                    value: .random(in: 4000...15000))
            steps.append(step)
        }
        return steps
    }
    
    
    static var weights: [HealthMetric] {
        var weights: [HealthMetric] = []
        for i in 0..<28 {
            let weight = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                    value: .random(in: 160 + Double(i/3)...165 + Double(i/3)))
            weights.append(weight)
        }
        print(" 😳 ")
        return weights
    }
}
