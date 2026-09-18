//
//  HealthKitManager.swift
//  StepTracker
//
//  Created by Shilan on 01/09/2026.
//

import Foundation
import HealthKit
import Observation

enum STError: LocalizedError{
    case authNotDetermined
    case sharingDenied(quantityType: String)
    case noData
    case unableToCompleteRequest
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .authNotDetermined:
            "Need access to Health data"
        case .sharingDenied(_):
            "No write access"
        case .noData:
            " No data"
        case .unableToCompleteRequest:
            "Unable to complete request"
        case .invalidData:
            "Invalid Data"
        }
    }
    
    var failureReason: String {
        switch self {
        case .authNotDetermined:
            "You have not given access to your Health data. Please go to Settings > Health > Data Access & Devices."
        case .sharingDenied(let quantityType):
            "You have denied access to upload your \(quantityType) data.\n\nYou can change this in Settings > Health > Data Access & Devices."
        case .noData:
            "There is no data for this Health statistic."
        case .unableToCompleteRequest:
            "We are unable to complete your request at this time.\n\nPlease try again later or contact support."
        case .invalidData:
            "Must be a numeric value with a maximum of one decimal place."
        }
    }
}


@Observable class HealthKitManager {
    let healthStore = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
    
    var stepsData: [HealthMetric] = []
    var weightsData: [HealthMetric] = []
    var weightsDiffData: [HealthMetric] = []
    
    func fetchStepCount() async throws {
        let status = healthStore.authorizationStatus(for: HKQuantityType(.stepCount))
        guard status != .notDetermined else {
            throw STError.authNotDetermined
        }
        
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
        
        do{
            let stepCounts = try await sumOfStepsQueryDescriptor.result(for: healthStore)
            stepsData = stepCounts.statistics().map {
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        }catch{
            throw STError.unableToCompleteRequest
        }
    }
    
    
    func fetchWeight() async throws {
        let status = healthStore.authorizationStatus(for: HKQuantityType(.bodyMass))
        guard status != .notDetermined else {
            throw STError.authNotDetermined
        }
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
        
        do{
            let weights = try await weightQueryDescriptor.result(for: healthStore)
            weightsData = weights.statistics().map{
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        }catch{
            throw STError.unableToCompleteRequest
        }
    }
    
    
    func fetchWeightForDifferentials() async throws{
        let status = healthStore.authorizationStatus(for: HKQuantityType(.bodyMass))
        guard status != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        let startDate = calendar.date(byAdding: .day, value: -29, to: endDate)!
        
        let QuaryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate) // A time range filter
        
        let weightType = HKQuantityType(.bodyMass)
        let samplePredicate = HKSamplePredicate.quantitySample(type: weightType, predicate: QuaryPredicate) // A typed sample predicate
        let dayInterval = DateComponents(day: 1)
        
        let weightQueryDescriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: endDate,
            intervalComponents: dayInterval)
        
        do{
            let weights = try await weightQueryDescriptor.result(for: healthStore)
            weightsDiffData = weights.statistics().map{
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




