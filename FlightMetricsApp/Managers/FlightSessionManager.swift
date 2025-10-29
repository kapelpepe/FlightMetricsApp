//
//  FlightSessionManager.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 26/10/2025.
//

import Foundation
import CoreData
import CoreLocation

class FlightSessionManager {
    static let shared = FlightSessionManager()
    private init() {}

    func createSession(from records: [FlightRecord], context: NSManagedObjectContext) -> FlightSession {
        let session = FlightSession(from: records, context: context)
        session.distance = FlightSessionManager.calculateDistance(for: records)
        session.flightTime = FlightSessionManager.calculateFlightTime(for: records)
        do {
            try context.save()
        } catch {
            print("Błąd zapisu sesji")
        }
        return session
    }

    static func calculateDistance(for records: [FlightRecord]) -> Double {
        guard records.count > 1 else { return 0 }
        var totalDistance: Double = 0
        for i in 1..<records.count {
            let start = CLLocation(latitude: records[i-1].latitude, longitude: records[i-1].longitude)
            let end = CLLocation(latitude: records[i].latitude, longitude: records[i].longitude)
            totalDistance += end.distance(from: start)
        }
        return totalDistance / 1000 // konwersja na kilometry
    }

    static func calculateFlightTime(for records: [FlightRecord]) -> Double {
        guard let first = records.first, let last = records.last else { return 0 }
        return last.timestamp.timeIntervalSince(first.timestamp)
    }

    static func formattedDate(_ session: FlightSession) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm dd.MM.yyyy"
        return formatter.string(from: session.startDate)
    }
    
    static func formattedFlightTime(_ session: FlightSession) -> String {
        let hours = Int(session.flightTime / 3600)
        let minutes = Int((session.flightTime.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)min"
    }
    
    static func deleteSession(_ session: FlightSession, in context: NSManagedObjectContext) {
        context.delete(session)
        do {
            try context.save()
        } catch {
            print("Błąd usuwania sesji")
        }
    }
}

extension FlightSessionManager { // rozszerzenie formatowania daty, potrzebne przy Total Time (Double)
    static func formattedFlightTime(_ totalSeconds: Double) -> String {
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)min"
    }
}
