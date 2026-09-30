//
//  Date+Ext.swift
//  StepTracker
//
//  Created by Shilan on 10/09/2026.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    var weekdayTitle: String {
        self.formatted(.dateTime.weekday(.wide))
    }
    
    var accesibilityDate: String{
        self.formatted(.dateTime.month(.wide).day())
    }
}
