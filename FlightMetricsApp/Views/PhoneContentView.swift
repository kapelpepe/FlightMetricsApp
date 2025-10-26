//
//  PhoneContentView.swift
//  FlightMetricsApp
//
//  Created by Kacper Gwiazda on 04/10/2025.
//

// POKI CO ZOSTAJE W CELACH TESTOWYCH! ODPIETY OD WindowGroup W FlightMetricsAppApp
import SwiftUI
import WatchConnectivity
import CoreData

struct PhoneContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest( // pobranie rekordów FlightRecord z Core Data
        sortDescriptors: [NSSortDescriptor(keyPath: \FlightRecord.timestamp, ascending: false)],
        animation: .default
    )
    
    private var records: FetchedResults<FlightRecord>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if records.isEmpty {
                    Text("Brak danych - uruchom tracking na zegarku")
                } else {
                    Text("Odebrano \(records.count) rekordów")
                        .bold()
                    ForEach(records.prefix(10), id: \.self) { (record: FlightRecord) in
                        let timestampInt = Int(record.timestamp.timeIntervalSince1970)
                        Text("""
                        t=\(timestampInt)
                        hr=\(Int(record.heartRateBPM))
                        p=\(Int(record.pressure))
                        relAlt=\(Int(record.relativeAltitude))
                        lat=\(record.latitude)
                        lon=\(record.longitude)
                        alt=\(Int(record.altitudeMeters))
                        speed=\(Int(record.speedKnots))
                        ax=\(record.ax)
                        ay=\(record.ay)
                        az=\(record.az)
                        gx=\(record.gx)
                        gy=\(record.gy)
                        gz=\(record.gz)
                        """)
                        .font(.system(size: 12, design: .monospaced))
                        .padding(.bottom, 4)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            PhoneSession.shared.onFlightDataReceived = { flightDataArray in
                for flightData in flightDataArray {
                    let _ = FlightRecord(from: flightData, context: viewContext)
                }
                do { try viewContext.save() } catch { print("Błąd zapisu Core Data") }
            }
        }
    }
}

#Preview {
    PhoneContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
