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
        ZStack (alignment: .topLeading) {
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
            RecordingOverlay(isRunning: $isRunning)
                .padding(5)
        }
        .padding()
        .onAppear {
            _ = WatchSession.shared
        }
    }
}

struct RecordingOverlay: View {
    @Binding var isRunning: Bool
    @State private var startDate = Date()
    @State private var elapsedTime = 0
    @State private var showDot = true
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 5) {
            if isRunning {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .opacity(showDot ? 1 : 0.2)
                
                Text(timeString(from: elapsedTime))
                    .font(.caption2)
                    .monospacedDigit()
            }
        }
        .onAppear {
            startDate = Date()
            elapsedTime = 0
            showDot = true
        }
        .onReceive(timer) { _ in
            guard isRunning else { return }
            elapsedTime = Int(Date().timeIntervalSince(startDate))
            showDot.toggle()
        }
        .padding(5)
        .background(Color.black.opacity(0.3))
        .cornerRadius(5)
    }
    
    func timeString(from seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
