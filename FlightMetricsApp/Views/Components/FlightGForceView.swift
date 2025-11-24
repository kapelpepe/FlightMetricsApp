//
//  FlightGForceView.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 08/11/2025.
//

import Foundation
import SwiftUI
import Charts

struct FlightGForceView: View {
    var records: [FlightRecord]
    
    private var gData: [(Date, Double)] {
        records.map {
            let g = sqrt(pow($0.ax, 2) + pow($0.ay, 2) + pow($0.az, 2))
            return ($0.timestamp, g)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Przeciążenie G")
                .font(.title2)
                .bold()
                .foregroundColor(.appFirstAccent)
            
            FlightChartCardView(
                title: "Siła G",
                data: gData,
                unit: "G",
                chartColor: { _ in .orange },
                height: 280,
                width: 400
            )
        }
    }
}
