//
//  SensorManager.swift
//  FlightMetricsAppWatch Watch App
//
//  Created by Gwiazda, Kacper on 13/10/2025.
//

import Foundation
import CoreLocation

class SensorManager: NSObject, ObservableObject {
    static let shared = SensorManager() // singleton
    private let locationManager = CLLocationManager()
    private var currentFlightData: [FlightData] = []
    private var isTracking = false
    
    private override init() { // inicjalizacja klasy
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startTracking() { // start trackingu
        guard !isTracking else { return }
        isTracking = true
        currentFlightData.removeAll()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() -> URL? { // stop trackingu
        guard isTracking else { return nil }
        isTracking = false
        locationManager.stopUpdatingLocation()
        let fileURL = saveDataToJSON()
        return fileURL
    }
    
    private func saveDataToJSON() -> URL? { // zapis do pliku JSON
        guard !currentFlightData.isEmpty else { return nil }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(currentFlightData)
            
            let filename = "flight_\(Int(Date().timeIntervalSince1970)).json"
            let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = folder.appendingPathComponent(filename)
            
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Błąd zapisu JSON: \(error)")
            return nil
        }
    }
}

extension SensorManager: CLLocationManagerDelegate { // rozszerzenie klasy o protokol stosowany do aktualizowania lokalizacji
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        guard let location = locations.last, location.horizontalAccuracy > 0 else { return }
        
        let newData = FlightData(from: location)
        currentFlightData.append(newData)
    }
}
