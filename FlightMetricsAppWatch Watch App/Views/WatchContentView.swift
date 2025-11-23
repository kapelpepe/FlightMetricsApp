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
                .offset(x: 0, y: -40)
        }
        .padding()
        .onAppear {
            _ = WatchSession.shared
        }
    }
}

struct RecordingOverlay: View {
    
    @Binding var isRunning: Bool
    @ObservedObject var sensorManager = SensorManager.shared
    
    @State private var showDot = true
    @State private var dotTimer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    var body: some View {
        if isRunning, let start = sensorManager.workoutStartDate {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .opacity(showDot ? 1.0 : 0.2)
                
                TimelineView(.periodic(from: Date(), by: 1)) { timeline in
                    Text(timeString(since: start, now: timeline.date))
                        .font(.caption2)
                        .monospacedDigit()
                }
            }
            .padding(6)
            .background(Color.black.opacity(0.3))
            .cornerRadius(6)
            .onReceive(dotTimer) { _ in
                showDot.toggle()
            }
        }
    }
    
    private func timeString(since start: Date, now: Date) -> String {
        let total = Int(now.timeIntervalSince(start))
        
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
