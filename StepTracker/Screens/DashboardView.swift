//
//  DashboardView.swift
//  StepTracker
//
//  Created by Shilan on 26/08/2026.
//

import SwiftUI
import Charts

enum HealthMetricContext: CaseIterable, Identifiable{
    case steps, weight
    var id: Self { self }
    
    var title: String {
        switch self {
        case .steps:
            return "Steps"
        case .weight:
            return "Weight"
        }
    }
}

struct DashboardView: View {
    
    @Environment(HealthKitManager.self) private var hkManager
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var isShowingPermissionPrimingSheet = false
    
    var isSteps: Bool { selectedStat == .steps}
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(spacing: 20){
                    
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    
                    switch selectedStat {
                    case .steps:
                        StepBarChart(chartData: hkManager.stepsData, selectedStat: .steps)
                        StepPieChart(pieChartData:ChartMath.averagePerWeek(for: hkManager.stepsData))
                    case .weight:
                        WeightLineChart(selectedStat: .weight, chartData: hkManager.weightsData)
                        WeightBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: hkManager.weightsData))
                    }
                }
            }
            .padding()
            .task {
                do{
                    try await hkManager.fetchStepCount()
                    try await hkManager.fetchWeight()
                    try await hkManager.fetchWeightForDifferentials()
                }catch STError.authNotDetermined{
                    isShowingPermissionPrimingSheet = true
                }catch STError.noData{
                    print("❌ There is no data to be shown.")
                }catch{
                    print("❌ Unable to complete the request.")
                }
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet) {
                //fetch health data
            } content: {
                HealthkitPermissionPrimingView()
            }
        }
        .tint(isSteps ? .pink : .indigo)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}

