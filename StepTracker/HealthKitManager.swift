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
}


 
