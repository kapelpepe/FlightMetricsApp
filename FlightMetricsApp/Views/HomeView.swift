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
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        HStack { // header
                            Image(systemName: "airplane.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.appFirstAccent)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Cześć!")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.appFirstAccent)
                                Text("Witaj w Flight Metrics ✈️")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        StatsCardView(sessions: sessions) // statystyki
                            .padding(.horizontal)
                        
                        Text("Ostatnie loty") // ostatnie loty
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            if sessions.isEmpty {
                                Text("Brak zapisanych lotów")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(sessions, id: \.id) { session in
                                    HStack {
                                        NavigationLink(destination: FlightDetailView(session: session)) {
                                            FlightCardView(session: session)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        //.swipeActions(edge: .trailing, allowsFullSwipe: true) { na symulatorze nie dziala poprawnie swipe karty w lewa strone, tymczasowe rozwiazanie
                                        Button(role: .destructive) {
                                            withAnimation {
                                                FlightSessionManager.deleteSession(session, in: viewContext)
                                            }
                                        } label: {
                                            // Label("Usuń", systemImage: "trash")
                                            Image(systemName: "trash")
                                        }
                                        //}
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
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
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

struct StatsCardView: View {
    var sessions: FetchedResults<FlightSession>
    
    var totalDistance: Double {
        sessions.reduce(0) { $0 + $1.distance }
    }
    
    var totalTime: Double {
        sessions.reduce(0) { $0 + $1.flightTime }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Statystyki")
                .font(.headline)
                .foregroundColor(.appFirstAccent)
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    Text("Ilość lotów:")
                    Text("\(sessions.count)")
                        .bold()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Łączny czas lotu:")
                    Text(FlightSessionManager.formattedFlightTime(totalTime))
                        .bold()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Łączny dystans:")
                    Text("\(String(format: "%.1f", totalDistance)) km")
                        .bold()
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
