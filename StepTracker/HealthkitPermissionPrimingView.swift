//
//  HealthkitPermissionPrimingView.swift
//  StepTracker
//
//  Created by Shilan on 28/08/2026.
//

import SwiftUI
import HealthKitUI

struct HealthkitPermissionPrimingView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingHealthKitPermission = false
    
    let desciption: String = """
        This app displays your step and weight data in interactive charts.
            
        You can also add new step or weight data to Apple Health from this app. Your data is private and secured.
        """
    
    
    var body: some View {
        VStack(spacing: 120){
            
            VStack(alignment: .leading, spacing: 10){
                Image(.appleHealthIcon)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .shadow(color: .gray.opacity(0.3), radius: 16)
                    .padding(.bottom,12)
                
                Text("Apple Health Integration")
                    .font(.title2).bold()
                Text(desciption)
                    .foregroundStyle(.secondary)
            }
            
            Button("Connect Apple Health") {
                isShowingHealthKitPermission = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .padding(25)
        .healthDataAccessRequest(store: hkManager.healthStore,
                                 shareTypes: hkManager.types,
                                 readTypes: hkManager.types,
                                 trigger: isShowingHealthKitPermission) { result in
            switch result {
            case .success(_):
                dismiss()
            case .failure(_):
                //handle the error later
                dismiss()
            }
        }
    }
}

#Preview {
    HealthkitPermissionPrimingView()
        .environment(HealthKitManager())
}
