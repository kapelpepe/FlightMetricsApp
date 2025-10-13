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
    
    var body: some View {
        VStack {
            Text(isRunning ? "W trakcie lotu" : "Lot zakonczony")
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
