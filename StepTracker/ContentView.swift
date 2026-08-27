//
//  ContentView.swift
//  StepTracker
//
//  Created by Shilan on 26/08/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(spacing: 20){
                    
                    VStack {
                        HStack {
                            VStack(alignment: .leading){
                                Label("Steps", systemImage: "figure.walk")
                                    .font(.title3.bold())
                                    .foregroundStyle(Color.pink)
                                Text("Avg: 10K Steps")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 12)
    
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 150)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.secondarySystemBackground))                    }
                    
                    
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
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    ContentView()
}
