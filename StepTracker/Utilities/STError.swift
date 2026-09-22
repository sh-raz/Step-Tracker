//
//  STError.swift
//  StepTracker
//
//  Created by Shilan on 21/09/2026.
//

import Foundation

enum STError: LocalizedError{
    case authNotDetermined
    case sharingDenied(quantityType: String)
    case noData
    case unableToCompleteRequest
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .authNotDetermined:
            "Need access to Health data"
        case .sharingDenied(_):
            "No write access"
        case .noData:
            " No data"
        case .unableToCompleteRequest:
            "Unable to complete request"
        case .invalidData:
            "Invalid Data"
        }
    }
    
    var failureReason: String {
        switch self {
        case .authNotDetermined:
            "You have not given access to your Health data. Please go to Settings > Health > Data Access & Devices."
        case .sharingDenied(let quantityType):
            "You have denied access to upload your \(quantityType) data.\n\nYou can change this in Settings > Health > Data Access & Devices."
        case .noData:
            "There is no data for this Health statistic."
        case .unableToCompleteRequest:
            "We are unable to complete your request at this time.\n\nPlease try again later or contact support."
        case .invalidData:
            "Must be a numeric value with a maximum of one decimal place."
        }
    }
}
