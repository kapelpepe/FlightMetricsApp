//
//  WatchContentView.swift
//  FlightMetricsAppWatch Watch App
//
//  Created by Kacper Gwiazda on 04/10/2025.
//

import SwiftUI
import WatchConnectivity

struct WatchContentView: View {
    @State private var isRunning = false
    
    @ObservedObject var sensorManager = SensorManager.shared
    
    let flightTypes = ["Lot rekreacyjny", "Lot służbowy", "Lot treningowy", "Inny"]
    
    var body: some View {
        VStack {
            Picker("Typ lotu", selection: $sensorManager.selectedFlightType) {
                ForEach(flightTypes, id: \.self) { type in
                    Text(type)
                }
            }
            .pickerStyle(.wheel)
            .disabled(isRunning)
            
            Text(isRunning ? "W trakcie lotu" : "Lot zakończony")
                .font(.headline)
                .padding(.top, 10)
            
            Button(isRunning ? "STOP" : "START") {
                if isRunning {
                    if let fileURL = SensorManager.shared.stopTracking() {
                        WatchSession.shared.sendFlightFileIfPossible(fileURL)
                    }
                } else {
                    SensorManager.shared.startTracking()
                }
                isRunning.toggle()
            }
            .tint(isRunning ? .red : .green)
        }
        .padding()
        .onAppear {
            _ = WatchSession.shared
        }
    }
}

#Preview {
    WatchContentView()
}
