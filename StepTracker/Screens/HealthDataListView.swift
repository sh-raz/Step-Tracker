//
//  HealthDataListView.swift
//  StepTracker
//
//  Created by Shilan on 27/08/2026.
//

import SwiftUI

struct HealthDataListView: View {
    
    var metric : HealthMetricContext
    @State private var isShowingAddData: Bool = false
    @State private var addedDataDate: Date = .now
    @State private var addedValue: String = ""
    
    var body: some View {
        List(0..<28) { i in
            HStack{
                Text(Date(), format: .dateTime.month().day().year())
                Spacer()
                Text(10000, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
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
                DatePicker("Date", selection: $addedDataDate,displayedComponents: .date)
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
                        //do code later
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        isShowingAddData = false
                    }
                }
            }
        }
    }
}
    
    #Preview {
        NavigationStack{
            HealthDataListView(metric: .steps)
        }
    }
