//
//  PhoneContentView.swift
//  FlightMetricsApp
//
//  Created by Kacper Gwiazda on 04/10/2025.
//

import SwiftUI
import WatchConnectivity

struct PhoneContentView: View {
    @State private var receivedData: [FlightData] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if receivedData.isEmpty {
                    Text("Brak danych - uruchom tracking na zegarku")
                } else {
                    Text("Odebrano \(receivedData.count) rekordów")
                        .bold()
                    ForEach(receivedData.prefix(10), id: \.timestamp) { data in
                        let timestampInt = Int(data.timestamp.timeIntervalSince1970)
                        Text("""
                        t=\(timestampInt)
                        hr=\(Int(data.heartRateBPM ?? 0))
                        p=\(Int(data.pressure ?? 0))
                        relAlt=\(Int(data.relativeAltitude ?? 0))
                        lat=\(data.latitude)
                        lon=\(data.longitude)
                        alt=\(Int(data.altitudeMeters))
                        speed=\(Int(data.speedKnots))
                        ax=\(data.ax ?? 0)
                        ay=\(data.ay ?? 0)
                        az=\(data.az ?? 0)
                        gx=\(data.gx ?? 0)
                        gy=\(data.gy ?? 0)
                        gz=\(data.gz ?? 0)
                        """)
                        .font(.system(size: 12, design: .monospaced))
                        .padding(.bottom, 4)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            PhoneSession.shared.onFlightDataReceived = { data in
                receivedData = data
            }
        }
    }
}

#Preview {
    PhoneContentView()
}
