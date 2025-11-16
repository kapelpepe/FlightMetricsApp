//
//  FlightChartsView.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 03/11/2025.
//

import Foundation
import SwiftUI
import Charts

struct FlightChartsView: View {
    var records: [FlightRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analiza lotu")
                .font(.title2)
                .bold()
                .foregroundColor(.appFirstAccent)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    
                    FlightChartCardView(
                        title: "Wysokość",
                        data: records.map { ($0.timestamp, $0.altitudeMeters) },
                        unit: "m"
                    )
                    
                    FlightChartCardView(
                        title: "Wysokość względna",
                        data: records.map { ($0.timestamp, $0.relativeAltitude) },
                        unit: "m"
                    )
                    
                    FlightChartCardView(
                        title: "Prędkość",
                        data: records.map { ($0.timestamp, $0.speedKnots) },
                        unit: "kn"
                    )
                    
                    FlightChartCardView(
                        title: "Ciśnienie",
                        data: records.map { ($0.timestamp, $0.pressure) },
                        unit: "hPa"
                    )
                }
                .padding(.vertical)
            }
        }
    }
}
