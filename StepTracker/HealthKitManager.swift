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
    
    
    func fetchStepCount() async {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            fatalError("*** Unable to calculate the end time ***") }
        guard let startDate = calendar.date(byAdding: .day, value: -28, to: endDate) else {
            fatalError("*** Unable to calculate the start time ***") }
        
        let QuaryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        let stepType = HKQuantityType(.stepCount)
        let samplePredicate = HKSamplePredicate.quantitySample(type: stepType, predicate: QuaryPredicate)
        let dayInterval = DateComponents(day: 1)
        
        let sumOfStepsQueryDescriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: endDate,
            intervalComponents: dayInterval)
        
        let stepCounts = try! await sumOfStepsQueryDescriptor.result(for: healthStore)
    }
    
    func fetchWeight() async {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!
        
        let QuaryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate) // A time range filter
        
        let weightType = HKQuantityType(.bodyMass)
        let samplePredicate = HKSamplePredicate.quantitySample(type: weightType, predicate: QuaryPredicate) // A typed sample predicate
        let dayInterval = DateComponents(day: 1)
        
        let weightQueryDescriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: endDate,
            intervalComponents: dayInterval)
        
        let weights = try! await weightQueryDescriptor.result(for: healthStore)
    }
    
    
    
    
    
    
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




