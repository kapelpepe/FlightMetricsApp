//
//  FlightData.swift
//  FlightMetricsAppWatch Watch App
//
//  Created by Gwiazda, Kacper on 13/10/2025.
//

import Foundation
import CoreLocation

struct FlightData: Codable, Identifiable {
    var id = UUID()
    let timestamp: Date
    let latitude: Double // szerokosc geograficzna
    let longitude: Double // dlugosc geograficzna
    let altitudeMeters: Double // wysokosc n.p.m pobierana z modulu GPS
    let speedKnots: Double // predkosc pobierana z GPS w m/s (konwertowana ponizej)
    
    init(from location: CLLocation) {
        self.timestamp = Date()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitudeMeters = location.altitude
        self.speedKnots = location.speed * 1.94384 // konwersja na węzły
    }
}
