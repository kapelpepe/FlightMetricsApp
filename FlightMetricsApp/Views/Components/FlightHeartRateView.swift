//
//  FlightHeartRateView.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 08/11/2025.
//

import Foundation
import SwiftUI
import Charts

struct FlightHeartRateView: View {
    var records: [FlightRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Zdrowie pilota")
                .font(.title2)
                .bold()
                .foregroundColor(.appFirstAccent)
            
            FlightChartCardView(
                title: "Tętno",
                data: records.map { ($0.timestamp, $0.heartRateBPM) },
                unit: "BPM",
                chartColor: { _ in .green },
                height: 280,
                width: 400
            )
        }
    }
}
