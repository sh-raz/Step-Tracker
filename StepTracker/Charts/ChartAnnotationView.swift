//
//  ChartAnnotationView.swift
//  StepTracker
//
//  Created by Shilan on 21/09/2026.
//

import SwiftUI

struct ChartAnnotationView: View {
    var selectedData: ChartDataModel
    var context: HealthMetricContext
    
    var body: some View {
        VStack{
            Text(selectedData.date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(Color.secondary)
            Text(selectedData.value, format: .number.precision(context == .steps ? .fractionLength(0) : .fractionLength(2)))
                .foregroundStyle(context == .steps ? Color.pink : (selectedData.value >= 0 ? Color.indigo : Color.mint))
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
    ChartAnnotationView(selectedData: .init(date: .now, value: 2000), context: .steps)
}
