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
            HStack{
                Text(data.date, format: .dateTime.month().day().year())
                Spacer()
                Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
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
                HStack{
                    Text(metric.title)
                    Spacer()
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
                        Task{
                            switch metric {
                            case .steps:
                                do{
                                    try await hkManager.addStepData(date: addedDate, value: Double(addedValue)!)
                                    try await hkManager.fetchStepCount()
                                    isShowingAddData = false
                                }catch STError.sharingDenied(let quantityType){
                                    writeError = .sharingDenied(quantityType: quantityType)
                                    isShowingAlert = true
                                }catch{
                                    writeError = .unableToCompleteRequest
                                    isShowingAlert = true
                                }
                                
                            case .weight:
                                do{
                                    try await hkManager.addWeightData(date: addedDate, value: Double(addedValue)!)
                                    try await hkManager.fetchWeight()
                                    try await hkManager.fetchWeightForDifferentials()
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
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        isShowingAddData = false
                    }
                }
            }
            .alert(isPresented: $isShowingAlert, error: writeError) { writeError in
                switch writeError {
                case .authNotDetermined, .noData, .unableToCompleteRequest:
                    EmptyView()
                case .sharingDenied(let quantityType):
                    
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
}
    
    #Preview {
        NavigationStack{
            HealthDataListView(metric: .steps)
                .environment(HealthKitManager())
        }
    }
