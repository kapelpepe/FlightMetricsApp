//
//  SensorManager.swift
//  FlightMetricsAppWatch Watch App
//
//  Created by Gwiazda, Kacper on 13/10/2025.
//

import Foundation
import CoreLocation // framework do obslugi modulu GPS
import CoreMotion // framework do obslugi barometru, akcelometru i zyroskopu
import HealthKit // framework do obslugi czujnika tetna

class SensorManager: NSObject, ObservableObject {
    static let shared = SensorManager() // singleton
    
    private let locationManager = CLLocationManager()
    private let barometer = CMAltimeter()
    private let healthStore = HKHealthStore()
    private let motionManager = CMMotionManager()
    
    @Published var currentPressure: Double? = nil
    @Published var currentHeartRate: Double? = nil
    @Published var accelerometerData: CMAccelerometerData? = nil
    @Published var gyroData: CMGyroData? = nil
    @Published var selectedFlightType: String = "Lot rekreacyjny"
    
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
        print("Start trackingu")
        guard !isTracking else { return }
        isTracking = true
        currentFlightData.removeAll()
        
        // MOCK - dane testowe
        let mockLocation = CLLocation(latitude: 52.2297, longitude: 21.0122) // Warszawa
        var firstData = FlightData(from: mockLocation)
        firstData.timestamp = Date()
        firstData.ax = 0.0
        firstData.ay = 0.0
        firstData.az = 0.0
        firstData.gx = 0.0
        firstData.gy = 0.0
        firstData.gz = 0.0
        firstData.heartRateBPM = 70
        firstData.pressure = 1013
        firstData.relativeAltitude = 10
        firstData.speedKnots = 10
        firstData.flightType = selectedFlightType
        
        let mockLocation2 = CLLocation(latitude: 52.2064, longitude: 20.9252)
        var secondData = FlightData(from: mockLocation2)
        secondData.timestamp = Date().addingTimeInterval(1800) // +30 minut
        secondData.ax = 0.2
        secondData.ay = 0.1
        secondData.az = 0.3
        secondData.gx = 0.05
        secondData.gy = 0.04
        secondData.gz = 0.06
        secondData.heartRateBPM = 85
        secondData.pressure = 1011
        secondData.relativeAltitude = 20
        secondData.speedKnots = 20
        secondData.flightType = selectedFlightType

        currentFlightData.append(contentsOf: [firstData, secondData])
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation() // start GPS
        startBarometer() // start barometru
        startHeartRateQuery() // start pomiaru tetna
        startIMU() // start IMU
        
    }
    
    func stopTracking() -> URL? { // stop trackingu
        guard isTracking else { return nil }
        isTracking = false
        locationManager.stopUpdatingLocation()
        barometer.stopRelativeAltitudeUpdates()
        stopIMU()
        
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
            print("JSON poprawnie zapisany")
            return fileURL
        } catch {
            print("Błąd zapisu JSON")
            return nil
        }
    }
    
    // OBSLUGA BAROMETRU
    
    private func startBarometer() {
        guard CMAltimeter.isRelativeAltitudeAvailable() else { return }
        
        barometer.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }
            
            let pressure = data.pressure.doubleValue * 10  // hPa
            self.currentPressure = pressure
            
            if self.isTracking, var last = self.currentFlightData.last {
                last.pressure = pressure
                last.relativeAltitude = data.relativeAltitude.doubleValue
                self.currentFlightData[self.currentFlightData.count - 1] = last
            }
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
    
    // OBSLUGA IMU (AKCELEROMETR + ZYROSKOP)
    
    private func startIMU() {
        guard motionManager.isAccelerometerAvailable || motionManager.isGyroAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 1.0 / 50.0 // 50 Hz
        motionManager.gyroUpdateInterval = 1.0 / 50.0 // 50 Hz
        
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let self = self, let data = data, error == nil else { return }
                self.accelerometerData = data
                
                if self.isTracking, var last = self.currentFlightData.last {
                    last.ax = data.acceleration.x
                    last.ay = data.acceleration.y
                    last.az = data.acceleration.z
                    self.currentFlightData[self.currentFlightData.count - 1] = last
                }
            }
        }
        
        if motionManager.isGyroAvailable {
            motionManager.startGyroUpdates(to: .main) { [weak self] data, error in
                guard let self = self, let data = data, error == nil else { return }
                self.gyroData = data
                
                if self.isTracking, var last = self.currentFlightData.last {
                    last.gx = data.rotationRate.x
                    last.gy = data.rotationRate.y
                    last.gz = data.rotationRate.z
                    self.currentFlightData[self.currentFlightData.count - 1] = last
                }
            }
        }
    }
    
    private func stopIMU() {
        if motionManager.isAccelerometerActive { motionManager.stopAccelerometerUpdates() }
        if motionManager.isGyroActive { motionManager.stopGyroUpdates() }
    }
}

extension SensorManager: CLLocationManagerDelegate { // rozszerzenie klasy o protokol stosowany do aktualizowania lokalizacji
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        
        guard let location = locations.last, location.horizontalAccuracy > 0 else { return }
        
        var newData = FlightData(from: location)
        
        newData.flightType = selectedFlightType
        
        newData.heartRateBPM = currentHeartRate
        
        if let acc = accelerometerData {
            newData.ax = acc.acceleration.x
            newData.ay = acc.acceleration.y
            newData.az = acc.acceleration.z
        }
        
        if let gyro = gyroData {
            newData.gx = gyro.rotationRate.x
            newData.gy = gyro.rotationRate.y
            newData.gz = gyro.rotationRate.z
        }
        
        currentFlightData.append(newData)
    }
}
