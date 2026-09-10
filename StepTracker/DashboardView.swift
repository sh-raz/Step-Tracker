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
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    @State private var isShowingPermissionPrimingSheet = false
    var isSteps: Bool { selectedStat == .steps}
    @State private var selectedDate: Date?
    
    var selectedHealthMetric: HealthMetric? {
        guard let selectedDate else {return nil}
        return hkManager.stepsData.first {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        }
    }
    
    var avgSteps: Double {
        guard !hkManager.stepsData.isEmpty else {return 0}
        let total = hkManager.stepsData.reduce(0) { $0 + $1.value }
        return total / Double(hkManager.stepsData.count)
    }
    
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
                    
                    
                    VStack {
                        NavigationLink(value: selectedStat) {
                            HStack {
                                VStack(alignment: .leading){
                                    Label("Steps", systemImage: "figure.walk")
                                        .font(.title3.bold())
                                        .foregroundStyle(Color.pink)
                                    Text("Avg: \(Int(avgSteps)) Steps")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.forward")
                            }
                        }
                        .padding(.bottom, 12)
                        .foregroundStyle(Color.secondary)
                        
                        Chart {
                            if let selectedHealthMetric {
                                RuleMark(x: .value("Selected Health Metric", selectedHealthMetric.date, unit: .day))
                                    .foregroundStyle(Color.secondary.opacity(0.3))
                                    .offset(y: -10)
                                    .annotation(position: .top,
                                                spacing: 0,
                                                overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                        annotationView                                   }
                            }
                            
                            RuleMark(y: .value("Average", avgSteps))
                                .lineStyle(.init(lineWidth: 0.6, dash: [5]))
                                .foregroundStyle(Color.secondary)
                            
                            ForEach(hkManager.stepsData) { step in
                                BarMark(
                                    x: .value("Date", step.date, unit: .day),
                                    y: .value("Steps", step.value)
                                )
                                .foregroundStyle(Color.pink.gradient)
                                .opacity(selectedDate == nil || selectedHealthMetric?.date == step.date ? 1.0 : 0.3)
                            }
                        }
                        .frame(height: 150)
                        .chartXSelection(value: $selectedDate.animation(.easeInOut))
                        .chartXAxis {
                            AxisMarks{
                                AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                            }
                        }
                        .chartYAxis{
                            AxisMarks { value in
                                AxisGridLine()
                                    .foregroundStyle(Color.secondary.opacity(0.3))
                                AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                            }
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.secondarySystemBackground))
                    }
                    
                    
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            Label("Averages", systemImage: "calendar")
                                .font(.title3.bold())
                                .foregroundStyle(Color.pink)
                            Text("Last 28 days")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 12)
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 240)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.secondarySystemBackground))
                    }
                }
            }
            .padding()
            .task {
                await hkManager.fetchStepCount()
                isShowingPermissionPrimingSheet = !hasSeenPermissionPriming
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet) {
                //fetch health data
            } content: {
                HealthkitPermissionPrimingView(hasSeen: $hasSeenPermissionPriming)
            }
        }
        .tint(isSteps ? .pink : .indigo)
    }
    
    var annotationView: some View {
        VStack{
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(Color.secondary)
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(0)))
                .foregroundStyle(Color.pink)
                .fontWeight(.heavy)
        }
        .padding(15)
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(Color(.secondarySystemBackground))
            .shadow(color: Color.secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
        
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}

