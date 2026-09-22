//
//  HealthDataListView.swift
//  StepTracker
//
//  Created by Shilan on 27/08/2026.
//

import SwiftUI

struct HealthDataListView: View {
    
    @Environment(HealthKitManager.self) private var hkManager
    @State private var isShowingAddData: Bool = false
    @State private var addedDate: Date = .now
    @State private var addedValue: String = ""
    @State private var isShowingAlert = false
    @State private var writeError: STError = .noData
    
    var metric : HealthMetricContext
    
    var listData: [HealthMetric] {
        metric == .steps ? hkManager.stepsData : hkManager.weightsData
    }
    
    var body: some View {
        List(listData.reversed()) { data in
            LabeledContent {
                Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
            } label: {
                Text(data.date, format: .dateTime.month().day().year())
            }
        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $isShowingAddData) {
            addDataView
        }
        .toolbar {
            Button("Add Data", systemImage: "plus") {
                isShowingAddData = true
            }
        }
    }
    
    
    var addDataView: some View {
        NavigationStack{
            Form {
                DatePicker("Date", selection: $addedDate,displayedComponents: .date)
                LabeledContent(metric.title) {
                    TextField("Value", text: $addedValue)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                        .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(metric.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        addData()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        isShowingAddData = false
                    }
                }
            }
            .alert(isPresented: $isShowingAlert, error: writeError) { writeError in
                switch writeError {
                case .authNotDetermined, .noData, .unableToCompleteRequest, .invalidData:
                    EmptyView()
                case .sharingDenied(_):
                    
                    Button("Settings") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    Button("Cancel", role: .cancel) { }
                }
            } message: { writeError in
                Text(writeError.failureReason)
            }
        }
    }
    
    private func addData() {
        guard let value = Double(addedValue) else {
            writeError = .invalidData
            isShowingAlert = true
            addedValue = ""
            return
        }
        Task{
            do{
                if metric == .steps {
                    try await hkManager.addStepData(date: addedDate, value: value)
                    hkManager.stepsData = try await hkManager.fetchStepCount(daysBack: 28)
                }else{
                    try await hkManager.addWeightData(date: addedDate, value: value)
                    async let weightsForLineChart = hkManager.fetchWeight(daysBack: 28)
                    async let weightsForDiffBarChart = hkManager.fetchWeight(daysBack: 29)
                    
                    hkManager.weightsData = try await weightsForLineChart
                    hkManager.weightsDiffData = try await weightsForDiffBarChart
                }
                isShowingAddData = false
            }catch STError.sharingDenied(let quantityType){
                writeError = .sharingDenied(quantityType: quantityType)
                isShowingAlert = true
            }catch{
                writeError = .unableToCompleteRequest
                isShowingAlert = true
            }
        }
        
    }
}

#Preview {
    NavigationStack{
        HealthDataListView(metric: .steps)
            .environment(HealthKitManager())
    }
}
