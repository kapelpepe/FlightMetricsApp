//
//  FlightBloodOxygenView.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 25/11/2025.
//

import Foundation
import SwiftUI
import Charts

struct FlightBloodOxygenView: View {
    var records: [FlightRecord]
    
    var body: some View {
        FlightChartCardView(
            title: "Natlenienie krwi",
            data: records.map { ($0.timestamp, $0.bloodOxygen) },
            unit: "%",
            chartColor: { _ in .mint },
            height: 280,
            width: 400
        )
    }
}
