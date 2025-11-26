//
//  FlightGyroscopeView.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 10/11/2025.
//

import Foundation
import SwiftUI
import Charts

struct FlightGyroscopeView: View {
    var records: [FlightRecord]
    
    private var rollData: [(Date, Double)] {
        records.map { ($0.timestamp, $0.gx) }
    }
    private var pitchData: [(Date, Double)] {
        records.map { ($0.timestamp, $0.gy) }
    }
    private var yawData: [(Date, Double)] {
        records.map { ($0.timestamp, $0.gz) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Orientacja (Yaw / Pitch / Roll)")
                .font(.title2)
                .bold()
                .foregroundColor(.appFirstAccent)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    FlightChartCardView( // roll
                        title: "Roll (obrót wokół osi X)",
                        data: rollData,
                        unit: "°",
                        chartColor: { _ in .red }
                    )
                    
                    FlightChartCardView( // pitch
                        title: "Pitch (obrót wokół osi Y)",
                        data: pitchData,
                        unit: "°",
                        chartColor: { _ in .green }
                    )
                    
                    FlightChartCardView( // yaw
                        title: "Yaw (obrót wokół osi Z)",
                        data: yawData,
                        unit: "°",
                        chartColor: { _ in .blue }
                    )
                }
                .padding(.vertical)
            }
        }
    }
}
