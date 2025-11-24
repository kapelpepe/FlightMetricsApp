//
//  FlightStatsManager.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 04/11/2025.
//

import Foundation
import SwiftUI

struct FlightStatsManager {
    static let zeroRange: ClosedRange<Double> = -0.05...0.05
    
    static func average(of values: [Double]) -> Double? { // średnia
        let valid = values.filter { !$0.isNaN } // ZASTANOWIC SIE NAD ODRZUCANIEM ZER && $0 != 0
        guard !valid.isEmpty else { return nil }
        let avg = valid.reduce(0, +) / Double(valid.count)
        return zeroRange.contains(avg) ? 0.0 : avg // eliminacja "ujemnych zer"
    }
    
    static func median(of values: [Double]) -> Double? { // mediana
        let valid = values.filter { !$0.isNaN }.sorted()
        guard !valid.isEmpty else { return nil }
        let mid = valid.count / 2
        let med: Double
        if valid.count % 2 == 0 {
            med = (valid[mid - 1] + valid[mid]) / 2
        } else {
            med = valid[mid]
        }
        return zeroRange.contains(med) ? 0.0 : med
    }
    
    static func minValue(of values: [Double]) -> Double? { // wartość minimalna
        let valid = values.filter { !$0.isNaN }
        guard let min = valid.min() else { return nil }
        return zeroRange.contains(min) ? 0.0 : min
    }
    
    static func maxValue(of values: [Double]) -> Double? { // wartość maksymalna
        let valid = values.filter { !$0.isNaN }
        guard let max = valid.max() else { return nil }
        return zeroRange.contains(max) ? 0.0 : max
    }
}
