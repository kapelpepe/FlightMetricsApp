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
    var timestamp: Date
    var latitude: Double // szerokosc geograficzna
    var longitude: Double // dlugosc geograficzna
    var altitudeMeters: Double // wysokosc n.p.m pobierana z modulu GPS
    var speedKnots: Double // predkosc pobierana z GPS w m/s (konwertowana ponizej)
    var pressure: Double? // cisnienie z barometru w hPa (moze byc nil przed rozpoczeciem dzialania czujnika - barometr dziala w trybie asynchronicznym)
    var relativeAltitude: Double? // wysokosc wzgledna (po starcie) pobierana z barometru
    var heartRateBPM: Double? // wartosc tetna w BPM pobrana z czujnika tetna
    var ax: Double? // koordynaty z akcelometru
    var ay: Double?
    var az: Double?
    var gx: Double? // koordynaty z zyroskopu
    var gy: Double?
    var gz: Double?
    
    init(from location: CLLocation) {
        self.timestamp = Date()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitudeMeters = location.altitude
        self.speedKnots = location.speed * 1.94384 // konwersja na węzły
        self.pressure = nil
        self.relativeAltitude = nil
        self.heartRateBPM = nil
        self.ax = nil
        self.ay = nil
        self.az = nil
        self.gx = nil
        self.gy = nil
        self.gz = nil
    }
}
