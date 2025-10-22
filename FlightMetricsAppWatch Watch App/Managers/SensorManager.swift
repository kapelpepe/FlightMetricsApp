//
//  SensorManager.swift
//  FlightMetricsAppWatch Watch App
//
//  Created by Gwiazda, Kacper on 13/10/2025.
//

import Foundation
import CoreLocation // framework do obslugi modulu GPS
import CoreMotion // framework do obslugi m.in. barometru
import HealthKit // framework do obslugi czujnika tetna

class SensorManager: NSObject, ObservableObject {
    static let shared = SensorManager() // singleton
    private let locationManager = CLLocationManager()
    private let barometer = CMAltimeter()
    private let healthStore = HKHealthStore()
    
    @Published var currentPressure: Double? = nil
    @Published var currentHeartRate: Double? = nil
    
    private var currentFlightData: [FlightData] = []
    private var isTracking = false
    private var heartRateQuery: HKQuery?
    
    private override init() { // inicjalizacja klasy
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestHeartRateAuthorization() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if success {
                print("Dostęp do tętna przyznany") // test czy dziala
            } else {
                print("Błąd przyznawania dostępu do tętna")
            }
        }
    }
    
    func startTracking() { // start trackingu
        guard !isTracking else { return }
        isTracking = true
        currentFlightData.removeAll()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation() // start GPS
        
        if CMAltimeter.isRelativeAltitudeAvailable() { // start barometru
            barometer.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in guard let self = self, let data = data, error == nil else { return }
                let pressure = data.pressure.doubleValue * 10  // hPa
                self.currentPressure = pressure
                
                if self.isTracking, var last = self.currentFlightData.last {
                    last.pressure = pressure
                    last.relativeAltitude = data.relativeAltitude.doubleValue
                    self.currentFlightData[self.currentFlightData.count - 1] = last
                }
            }
        }
    }
    
    func stopTracking() -> URL? { // stop trackingu
        guard isTracking else { return nil }
        isTracking = false
        locationManager.stopUpdatingLocation()
        barometer.stopRelativeAltitudeUpdates()
        
        if let query = heartRateQuery {
            healthStore.stop(query)
        }
        
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
    
    // OBSLUGA CZUJNIKA TETNA
    
    private func startHeartRateQuery() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)
        
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] _, samples, _, _, _ in
            self?.processHeartRateSamples(samples)
        }
        
        query.updateHandler = { [weak self] (_: HKAnchoredObjectQuery, samples: [HKSample]?, _: [HKDeletedObject]?, _: HKQueryAnchor?, _: Error?) in
            self?.processHeartRateSamples(samples)
        }
        
        healthStore.execute(query)
        self.heartRateQuery = query
    }
    
    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample], let lastSample = samples.last else { return }
        let bpm = lastSample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        DispatchQueue.main.async {
            self.currentHeartRate = bpm
            if self.isTracking, var last = self.currentFlightData.last {
                last.heartRateBPM = bpm
                self.currentFlightData[self.currentFlightData.count - 1] = last
            }
        }
    }
}

extension SensorManager: CLLocationManagerDelegate { // rozszerzenie klasy o protokol stosowany do aktualizowania lokalizacji
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        guard let location = locations.last, location.horizontalAccuracy > 0 else { return }
        
        var newData = FlightData(from: location)
        newData.heartRateBPM = currentHeartRate
        currentFlightData.append(newData)
    }
}
