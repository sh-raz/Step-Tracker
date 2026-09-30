//
//  Array+Ext.swift
//  StepTracker
//
//  Created by Shilan on 22/09/2026.
//

import Foundation

extension Array where Element == Double {
    var average: Double {
        guard !self.isEmpty else { return 0 }
        let total = self.reduce(0, +)
        return total/Double(self.count)
    }
}

