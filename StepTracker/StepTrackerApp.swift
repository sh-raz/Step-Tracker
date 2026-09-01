//
//  StepTrackerApp.swift
//  StepTracker
//
//  Created by Shilan on 26/08/2026.
//

import SwiftUI

@main
struct StepTrackerApp: App {
    let hkManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(hkManager)
        }
    }
}
