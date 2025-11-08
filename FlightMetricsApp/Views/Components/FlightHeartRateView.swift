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
                chartColor: { val in
                    guard let val = val else { return .gray }
                    switch val {
                    case ..<60: return .blue
                    case 60..<120: return .green
                    case 120..<160: return .yellow
                    case 160...: return .red
                    default: return .gray
                    }
                },
                height: 280,
                width: 360
            )
        }
    }
}
