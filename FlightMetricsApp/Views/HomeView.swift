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
    
    @State private var showUndoBanner = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        HStack {
                            HStack { // header
                                Image("AppIconLogo")
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
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(.appFirstAccent)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        StatsCardView(sessions: sessions) // statystyki
                            .padding(.horizontal)
                        
                        Text("Ostatnie loty") // ostatnie loty
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                            .foregroundColor(.textPrimary)
                        
                        VStack(spacing: 16) {
                            if sessions.isEmpty {
                                Text("Brak zapisanych lotów")
                                    .foregroundColor(.textSecondary)
                                    .padding()
                            } else {
                                ForEach(sessions, id: \.id) { session in
                                    HStack {
                                        NavigationLink(destination: FlightDetailView(session: session)) {
                                            FlightCardView(session: session)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        Button(role: .destructive) {
                                            withAnimation {
                                                viewContext.delete(session)
                                                showUndoBanner = true
                                            }
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                                                if showUndoBanner {
                                                    do {
                                                        try viewContext.save()
                                                    } catch {
                                                        print("Błąd zapisu po usunięciu")
                                                    }
                                                    withAnimation {
                                                        showUndoBanner = false
                                                    }
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewContext.delete(session)
                                        } label: {
                                            Label("Usuń", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                }
                
                VStack {
                    Spacer()
                    
                    if showUndoBanner {
                        HStack {
                            Text("Sesja usunięta")
                                .foregroundColor(.white)
                            Spacer()
                            Button("Cofnij") {
                                viewContext.rollback()
                                withAnimation {
                                    showUndoBanner = false
                                }
                            }
                            .bold()
                            .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .shadow(radius: 5)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                
            }
            .navigationTitle("") // dla ukrycia podstawowego tytulu nawigacji
            .navigationBarHidden(true)
        }
        .onAppear {
            PhoneSession.shared.onFlightDataReceived = { flightDataArray in
                let records = flightDataArray.map { FlightRecord(from: $0, context: viewContext) }
                do { try viewContext.save() } catch { print("Błąd zapisu Core Data") }
                
                let session = FlightSession(from: records, context: viewContext)
                do { try viewContext.save() } catch { print("Błąd zapisu FlightSession") }
            }
        }
    }
}

struct FlightCardView: View {
    var session: FlightSession
    
    var body: some View {
        let formattedDate = FlightSessionManager.formattedDate(session)
        let formattedTime = FlightSessionManager.formattedFlightTime(session)
        let formattedDistance = FlightSessionManager.formattedDistance(session)
        
        return VStack(alignment: .leading, spacing: 6) {
            FlightMapView(coordinates: session.routeCoordinates, interactive: false,
                edgePadding: UIEdgeInsets(top:40, left: 20, bottom: 20, right: 20))
                .frame(height: 120)
                .cornerRadius(10)
            Text("\(session.flightType)")
                .font(.headline)
            Text(formattedDate)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            HStack {
                Text("Dystans: \(formattedDistance)")
                Spacer()
                Text("Czas lotu: \(formattedTime)")
            }
            .font(.footnote)
            .foregroundColor(.textSecondary)
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
                    Text(FlightSessionManager.formattedDistance(totalDistance))
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
