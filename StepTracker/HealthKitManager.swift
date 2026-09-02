//
//  HealthKitManager.swift
//  StepTracker
//
//  Created by Shilan on 01/09/2026.
//

import Foundation
import HealthKit
import Observation

@Observable class HealthKitManager {
    let healthStore = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
    
    
//    func addSimulatorData() async {
//        var samples: [HKQuantitySample] = []
//        
//        let stepType = HKQuantityType(.stepCount)
//        let weightType = HKQuantityType(.bodyMass)
//        
//        for i in 0..<28 {
//            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
//            let endDate = Calendar.current.date(byAdding: .minute, value: 1, to: startDate)!
//            
//            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4000...20000))
//            let weightQuantity = HKQuantity(unit: .pound(), doubleValue: .random(in: 160 + Double(i/3)...165 + Double(i/3)))
//            
//            let stepSample = HKQuantitySample(type: stepType, quantity: stepQuantity, start: startDate, end: endDate)
//            let weightSample = HKQuantitySample(type: weightType, quantity: weightQuantity, start: startDate, end: endDate)
//            
//            samples.append(stepSample)
//            samples.append(weightSample)
//        }
//        do{
//            try await healthStore.save(samples) // try!
//            print("Dummy data sent up ✅")
//        }catch{
//            print("error")
//        }
//    }
}


 
