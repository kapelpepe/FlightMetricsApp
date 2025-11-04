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
    
    @State private var showStats = false
    
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
            
            Button {
                withAnimation(.spring()) {
                    showStats.toggle()
                }
            } label: {
                HStack {
                    Text("Statystyki")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.appFirstAccent)
                    Image(systemName: showStats ? "chevron.up" : "chevron.down")
                        .foregroundColor(.appFirstAccent)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .padding(.top, 4)
            
            if showStats {
                VStack(alignment: .leading, spacing: 4) {
                    let values = data.map { $0.1 }
                    if let avg = FlightStatsManager.average(of: values) {
                        Text("Średnia: \(String(format: "%.1f", avg)) \(unit)")
                    }
                    if let median = FlightStatsManager.median(of: values) {
                        Text("Mediana: \(String(format: "%.1f", median)) \(unit)")
                    }
                    if let max = FlightStatsManager.maxValue(of: values) {
                        Text("Maksimum: \(String(format: "%.1f", max)) \(unit)")
                    }
                    if let min = FlightStatsManager.minValue(of: values) {
                        Text("Minimum: \(String(format: "%.1f", min)) \(unit)")
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .frame(width: 280)
        .background(Color(.cardBackground))
        .cornerRadius(16)
        .shadow(radius: 3)
    }
}
