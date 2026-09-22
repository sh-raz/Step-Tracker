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
    @State private var isShowingAlert = false
    @State private var fetchError: STError = .noData

    
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
                        StepBarChart(chartData: ChartHelper.converToChartData(data: hkManager.stepsData))
                        StepPieChart(chartData:ChartMath.averagePerWeek(for: hkManager.stepsData))
                    case .weight:
                        WeightLineChart(chartData: ChartHelper.converToChartData(data: hkManager.weightsData))
                        WeightBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: hkManager.weightsData))
                    }
                }
            }
            .padding()
            .task {
                fetchHealthData()
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                //action
            } message: { fetchError in
                Text(fetchError.failureReason)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet) {
                fetchHealthData()
            } content: {
                HealthkitPermissionPrimingView()
            }
        }
        .tint(selectedStat == .steps ? .pink : .indigo)
    }
    
    
    
    private func fetchHealthData() {
        Task {
            do {
                async let steps = hkManager.fetchStepCount(daysBack: 28)
                async let weightsForLineChart = hkManager.fetchWeight(daysBack: 28)
                async let weightsForDiffBarChart = hkManager.fetchWeight(daysBack: 29)
                
                hkManager.stepsData = try await steps
                hkManager.weightsData = try await weightsForLineChart
                hkManager.weightsDiffData = try await weightsForDiffBarChart
                
            } catch STError.authNotDetermined{
                isShowingPermissionPrimingSheet = true
            } catch STError.noData{
                fetchError = .noData
                isShowingAlert = true
            } catch{
                fetchError = .unableToCompleteRequest
                isShowingAlert = true
            }
        }
    }
}


#Preview {
    DashboardView()
        .environment(HealthKitManager())
}

