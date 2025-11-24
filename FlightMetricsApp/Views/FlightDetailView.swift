//
//  FlightDetailView.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 27/10/2025.
//

import Foundation
import SwiftUI

struct FlightDetailView: View {
    var session: FlightSession
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Szczegóły lotu")
                        .font(.title)
                        .bold()
                        .padding(.bottom, 8)
                        .foregroundColor(.appFirstAccent)
                    
                    FlightMapView(coordinates: session.routeCoordinates, interactive: true)
                        .frame(height: 300)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .padding(.bottom)
                    
                    Group {
                        HStack {
                            Text("Data:")
                            Spacer()
                            Text(FlightSessionManager.formattedDate(session))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Czas trwania:")
                            Spacer()
                            Text(FlightSessionManager.formattedFlightTime(session))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Dystans:")
                            Spacer()
                            Text(FlightSessionManager.formattedDistance(session))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Liczba rekordów:")
                            Spacer()
                            Text("\(session.records?.count ?? 0)")
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.headline)
                    
                    Divider()
                    
                    if let records = session.records?.sorted(by: { $0.timestamp < $1.timestamp }) {
                        FlightChartsView(records: records)
                    }
                    
                    Divider()
                    
                    if let records = session.records?.sorted(by: { $0.timestamp < $1.timestamp }) {
                        FlightGyroscopeView(records: records)
                    }
                    
                    Divider()
                    
                    if let records = session.records?.sorted(by: { $0.timestamp < $1.timestamp }) {
                        FlightHeartRateView(records: records)
                    }
                    
                    Divider()
                    
                    if let records = session.records?.sorted(by: { $0.timestamp < $1.timestamp }) {
                        FlightGForceView(records: records)
                    }
                    
                    Text("Dane z FlightRecords")
                        .font(.title3)
                        .padding(.top, 10)
                    
                    if let records = session.records?.sorted(by: { $0.timestamp < $1.timestamp }) {
                        ForEach(records.prefix(10), id: \.self) { record in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Data: \(record.timestamp.formatted())")
                                Text("Tętno: \(Int(record.heartRateBPM)) bpm")
                                Text("Wysokość: \(Int(record.altitudeMeters)) m")
                                Text("Prędkość: \(Int(record.speedKnots)) kn")
                                Text("Ciśnienie: \(Int(record.pressure)) hPa")
                                Text("Ax: \(Double(record.ax))")
                                Text("Ay: \(Double(record.ay))")
                                Text("Az: \(Double(record.az))")
                                Text("Gx: \(Double(record.gx))")
                                Text("Gy: \(Double(record.gy))")
                                Text("Gz: \(Double(record.gz))")
                            }
                            .font(.footnote)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("\(session.flightType)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
