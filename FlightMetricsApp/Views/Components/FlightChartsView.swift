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
                        title: "Tętno",
                        color: .appFirstAccent,
                        data: records.map { ($0.timestamp, $0.heartRateBPM) },
                        unit: "BPM"
                    )
                    
                    FlightChartCardView(
                        title: "Wysokość względna",
                        color: .appFirstAccent,
                        data: records.map { ($0.timestamp, $0.relativeAltitude) },
                        unit: "m"
                    )
                    
                    FlightChartCardView(
                        title: "Prędkość",
                        color: .appFirstAccent,
                        data: records.map { ($0.timestamp, $0.speedKnots) },
                        unit: "kn"
                    )
                }
                .padding(.vertical)
            }
        }
    }
}

struct FlightChartCardView: View {
    let title: String
    let color: Color
    let data: [(Date, Double)]
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)
            
            Chart {
                ForEach(data, id: \.0) { point in
                    LineMark(
                        x: .value("Czas", point.0),
                        y: .value(title, point.1)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(color)
                }
            }
            .frame(height: 180)
            
            if let avg = averageValue {
                Text("Średnio: \(String(format: "%.1f", avg)) \(unit)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 280)
        .background(Color(.cardBackground))
        .cornerRadius(16)
        .shadow(radius: 3)
    }
    
    private var averageValue: Double? {
        let valid = data.map { $0.1 }.filter { !$0.isNaN && $0 != 0 }
        guard !valid.isEmpty else { return nil }
        return valid.reduce(0, +) / Double(valid.count)
    }
}
