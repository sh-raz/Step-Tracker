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
    
    var stepsData: [HealthMetric] = []
    var weightsData: [HealthMetric] = []
    var weightsDiffData: [HealthMetric] = []
    
    func fetchStepCount(daysBack: Int) async throws -> [HealthMetric] {
        let status = healthStore.authorizationStatus(for: HKQuantityType(.stepCount))
        guard status != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createTimeInterval(from: .now, daysBack: daysBack)
        let QuaryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        
        let stepType = HKQuantityType(.stepCount)
        let samplePredicate = HKSamplePredicate.quantitySample(type: stepType, predicate: QuaryPredicate)
        let dayInterval = DateComponents(day: 1)
        
        let sumOfStepsQueryDescriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: interval.end,
            intervalComponents: dayInterval)
        
        do{
            let stepCounts = try await sumOfStepsQueryDescriptor.result(for: healthStore)
            return stepCounts.statistics().map {
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        }catch{
            throw STError.unableToCompleteRequest
        }
    }
    
    
    func fetchWeight(daysBack: Int) async throws -> [HealthMetric] {
        let status = healthStore.authorizationStatus(for: HKQuantityType(.bodyMass))
        guard status != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let dateInterval = createTimeInterval(from: .now, daysBack: daysBack)
        let QuaryPredicate = HKQuery.predicateForSamples(withStart: dateInterval.start, end: dateInterval.end) // A time range filter
        
        let weightType = HKQuantityType(.bodyMass)
        let samplePredicate = HKSamplePredicate.quantitySample(type: weightType, predicate: QuaryPredicate) // A typed sample predicate
        let dayInterval = DateComponents(day: 1)
        
        let weightQueryDescriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: dateInterval.end,
            intervalComponents: dayInterval)
        
        do{
            let weights = try await weightQueryDescriptor.result(for: healthStore)
            return weights.statistics().map{
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        }catch{
            throw STError.unableToCompleteRequest
        }
    }
    
    
    func addStepData(date: Date, value: Double) async throws {
        let status = healthStore.authorizationStatus(for: HKQuantityType(.stepCount))
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "step count")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let StepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: date, end: date)
        do{
            try await healthStore.save(StepSample)
        }catch{
            throw STError.unableToCompleteRequest
        }
    }
    
    
    func addWeightData(date: Date, value: Double) async throws {
        let status = healthStore.authorizationStatus(for: HKQuantityType(.stepCount))
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "weight")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        let weightQuantity = HKQuantity(unit: .pound(), doubleValue: value)//.gramUnit(with: .kilo)
        let WeightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: date, end: date)
        do{
            try await healthStore.save(WeightSample)
        }catch{
            throw STError.unableToCompleteRequest
        }
    }
    
    
    private func createTimeInterval(from date: Date, daysBack: Int) -> DateInterval {
        let calendar = Calendar.current
        let startOfEndDay = calendar.startOfDay(for: date)
        let endOfEndDay = calendar.date(byAdding: .day, value: 1, to: startOfEndDay)!
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: endOfEndDay)!
        return .init(start: startDate, end: endOfEndDay) //end of the end date
    }
    
    
//        func addSimulatorData() async {
//            var samples: [HKQuantitySample] = []
//    
//            let stepType = HKQuantityType(.stepCount)
//            let weightType = HKQuantityType(.bodyMass)
//    
//            for i in 0..<28 {
//                let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
//                let endDate = Calendar.current.date(byAdding: .minute, value: 1, to: startDate)!
//    
//                let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4000...20000))
//                let weightQuantity = HKQuantity(unit: .pound(), doubleValue: .random(in: 160 + Double(i/3)...165 + Double(i/3)))
//    
//                let stepSample = HKQuantitySample(type: stepType, quantity: stepQuantity, start: startDate, end: endDate)
//                let weightSample = HKQuantitySample(type: weightType, quantity: weightQuantity, start: startDate, end: endDate)
//    
//                samples.append(stepSample)
//                samples.append(weightSample)
//            }
//            do{
//                try await healthStore.save(samples) // try!
//                print("Dummy data sent up ✅")
//            }catch{
//                print("error")
//            }
//        }
}




