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
    var pressure: Double? // cisnienie z barometru w hPa (moze byc nil przed rozpoczeciem dzialania czujnika - barometr dziala w trybie asynchronicznym)
    var relativeAltitude: Double? // wysokosc wzgledna (po starcie) pobierana z barometru
    var heartRateBPM: Double? // wartosc tetna w BPM pobrana z czujnika tetna
    
    init(from location: CLLocation) {
        self.timestamp = Date()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitudeMeters = location.altitude
        self.speedKnots = location.speed * 1.94384 // konwersja na węzły
        self.pressure = nil
        self.relativeAltitude = nil
        self.heartRateBPM = nil
    }
}
