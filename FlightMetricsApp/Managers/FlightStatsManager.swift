//
//  FlightStatsManager.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 04/11/2025.
//

import Foundation
import SwiftUI

struct FlightStatsManager {
    
    static func average(of values: [Double]) -> Double? { // średnia
        let valid = values.filter { !$0.isNaN } // ZASTANOWIC SIE NAD ODRZUCANIEM ZER && $0 != 0
        guard !valid.isEmpty else { return nil }
        return valid.reduce(0, +) / Double(valid.count)
    }
    
    static func median(of values: [Double]) -> Double? { // mediana
        let valid = values.filter { !$0.isNaN && $0 != 0 }.sorted()
        guard !valid.isEmpty else { return nil }
        let mid = valid.count / 2
        if valid.count % 2 == 0 {
            return (valid[mid - 1] + valid[mid]) / 2
        } else {
            return valid[mid]
        }
    }
    
    static func minValue(of values: [Double]) -> Double? { // wartość minimalna
        let valid = values.filter { !$0.isNaN && $0 != 0 }
        return valid.min()
    }
    
    static func maxValue(of values: [Double]) -> Double? { // wartość maksymalna
        let valid = values.filter { !$0.isNaN && $0 != 0 }
        return valid.max()
    }
}
