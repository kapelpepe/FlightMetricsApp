//
//  HomeView.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 26/10/2025.
//

import Foundation
import CoreData
import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FlightSession.startDate, ascending: false)],
        animation: .default
    )
    
    private var sessions: FetchedResults<FlightSession>
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Ostatnie loty")
                    .font(.title2)
                    .bold()
                    .padding([.top, .horizontal])
                ScrollView {
                    VStack(spacing: 12) {
                        if sessions.isEmpty {
                            Text("Brak zapisanych lotów")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(sessions, id: \.id) { session in
                                FlightCardView(session: session)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("") // dla ukrycia podstawowego tytulu nawigacji
            .navigationBarHidden(true)
        }
        .onAppear {
            PhoneSession.shared.onFlightDataReceived = { flightDataArray in
                let records = flightDataArray.map { FlightRecord(from: $0, context: viewContext) }
                do { try viewContext.save() } catch { print("Błąd zapisu Core Data") }
                
                // Teraz tworzysz FlightSession z tych rekordów
                let session = FlightSession(from: records, context: viewContext)
                do { try viewContext.save() } catch { print("Błąd zapisu FlightSession") }
            }
        }
    }
}

struct FlightCardView: View {
    var session: FlightSession
    
    var body: some View {
        var formattedDate = FlightSessionManager.formattedDate(session)
        let formattedTime = FlightSessionManager.formattedFlightTime(session)
        
        return VStack(alignment: .leading, spacing: 6) {
            Text("Lot rekreacyjny")
                .font(.headline)
            Text(formattedDate)
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Text("Dystans: \(String(format: "%.1f", session.distance)) km")
                Spacer()
                Text("Czas lotu: \(formattedTime)")
            }
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
