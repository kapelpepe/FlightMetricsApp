//
//  SensorManager.swift
//  FlightMetricsAppWatch Watch App
//
//  Created by Gwiazda, Kacper on 13/10/2025.
//

import Foundation
import CoreLocation // framework do obslugi modulu GPS
import CoreMotion // framework do obslugi barometru, akcelometru i zyroskopu
import HealthKit // framework do obslugi czujnika tetna i natlenienia krwi

class SensorManager: NSObject, ObservableObject {
    static let shared = SensorManager() // singleton
    
    private let locationManager = CLLocationManager()
    private let barometer = CMAltimeter()
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private let motionManager = CMMotionManager()
    
    @Published var currentPressure: Double? = nil
    @Published var currentHeartRate: Double? = nil
    @Published var currentBloodOxygen: Double? = nil
    @Published var accelerometerData: CMAccelerometerData? = nil
    @Published var gyroData: CMDeviceMotion? = nil
    @Published var selectedFlightType: String = "Lot rekreacyjny"
    @Published var workoutStartDate: Date? // czas sesji treningowej wykorzystywany w UI
    
    private var currentFlightData: [FlightData] = []
    private var isTracking = false
    private var heartRateQuery: HKQuery?
    private var lastUpdateTime: Date? = nil
    private var roll: Double = 0.0
    private var pitch: Double = 0.0
    private var yaw: Double = 0.0
    
    private override init() { // inicjalizacja klasy
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermissionIfNeeded() {
        let status = locationManager.authorizationStatus
        
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func startBackgroundWorkout() {
        let config = HKWorkoutConfiguration()
        config.activityType = .other
        config.locationType = .outdoor
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            workoutSession?.startActivity(with: Date())
            workoutStartDate = Date()
        } catch {
            print("Workout error")
        }
    }
    
    func stopBackgroundWorkout() {
        workoutSession?.stopActivity(with: Date())
        workoutSession?.end()
        workoutStartDate = nil
    }
    
    func startTracking() { // start trackingu
        print("Start trackingu")
        print("Akcelerometr dostepny: \(motionManager.isAccelerometerAvailable)") // test dostepnosci
        print("Gyro dostepny: \(motionManager.isGyroAvailable)")
        print("DeviceMotion dostepny: \(motionManager.isDeviceMotionAvailable)")
        guard !isTracking else { return }
        isTracking = true
        currentFlightData.removeAll()
        requestLocationPermissionIfNeeded()
        startBackgroundWorkout()
        
        // MOCK - dane testowe
        /*
        let mockLocation = CLLocation(latitude: 52.2297, longitude: 21.0122) // Warszawa
        var firstData = FlightData(from: mockLocation)
        firstData.timestamp = Date()
        firstData.ax = 0.0
        firstData.ay = 0.0
        firstData.az = -1.0
        firstData.gx = 5.0
        firstData.gy = 2.5
        firstData.gz = 45.0
        firstData.heartRateBPM = 70
        firstData.pressure = 1013
        firstData.relativeAltitude = 10
        firstData.speedKnots = 10
        firstData.flightType = selectedFlightType
        
        let mockLocation2 = CLLocation(latitude: 52.2064, longitude: 20.9252)
        var secondData = FlightData(from: mockLocation2)
        secondData.timestamp = Date().addingTimeInterval(1800) // +30 minut
        secondData.ax = 0.0
        secondData.ay = 0.2
        secondData.az = -1.2
        secondData.gx = -10.0
        secondData.gy = 5.0
        secondData.gz = 100.0
        secondData.heartRateBPM = 85
        secondData.pressure = 1011
        secondData.relativeAltitude = 20
        secondData.speedKnots = 20
        secondData.flightType = selectedFlightType

        currentFlightData.append(contentsOf: [firstData, secondData])
        */
        
        startBarometer() // start barometru
        startHeartRateQuery() // start pomiaru tetna
        startBloodOxygenQuery() // start pomiaru natlenienia krwi
        startIMU() // start IMU
        locationManager.startUpdatingLocation() // start GPS
    }
    
    func stopTracking() -> URL? { // stop trackingu
        print("Stop trackingu")
        guard isTracking else { return nil }
        isTracking = false
        barometer.stopRelativeAltitudeUpdates()
        stopIMU()
        
        if let query = heartRateQuery {
            healthStore.stop(query)
        }
        
        locationManager.stopUpdatingLocation()
        stopBackgroundWorkout()
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
    
    // OBSLUGA CZUJNIKA NATLENIENIA KRWI
    
    private func startBloodOxygenQuery() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let oxygenType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        
        let query = HKStatisticsQuery(quantityType: oxygenType,
                                      quantitySamplePredicate: nil,
                                      options: .mostRecent) { [weak self] _, result, _ in
            guard let self = self else { return }
            if let quantity = result?.mostRecentQuantity() {
                let percentage = quantity.doubleValue(for: HKUnit.percent()) * 100
                DispatchQueue.main.async {
                    self.currentBloodOxygen = percentage
                    if self.isTracking, var last = self.currentFlightData.last {
                        last.bloodOxygen = percentage
                        self.currentFlightData[self.currentFlightData.count - 1] = last
                    }
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // OBSLUGA IMU (AKCELEROMETR + ZYROSKOP)
    
    private func startIMU() {
        guard motionManager.isAccelerometerAvailable || motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 1.0 / 50.0 // 50 Hz
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0 // 50 Hz
        
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
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let self = self, let motion = motion, error == nil else { return }
                self.gyroData = motion
                
                if self.isTracking, var last = self.currentFlightData.last {
                    last.gx = motion.attitude.roll * 180 / .pi
                    last.gy = motion.attitude.pitch * 180 / .pi
                    last.gz = motion.attitude.yaw * 180 / .pi
                    self.currentFlightData[self.currentFlightData.count - 1] = last
                }
            }
        }
    }
    
    private func stopIMU() {
        if motionManager.isAccelerometerActive { motionManager.stopAccelerometerUpdates() }
        if motionManager.isDeviceMotionActive { motionManager.stopDeviceMotionUpdates() }
    }
}

extension SensorManager: CLLocationManagerDelegate { // rozszerzenie klasy o protokol stosowany do aktualizowania lokalizacji
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        
        guard let location = locations.last, location.horizontalAccuracy > 0 else { return }
        
        var newData = FlightData(from: location)
        
        newData.flightType = selectedFlightType
        
        newData.heartRateBPM = currentHeartRate
        
        newData.bloodOxygen = currentBloodOxygen
        
        newData.pressure = currentPressure
        
        if let acc = accelerometerData {
            newData.ax = acc.acceleration.x
            newData.ay = acc.acceleration.y
            newData.az = acc.acceleration.z
        }
        
        if let gyro = gyroData {
            newData.gx = gyro.attitude.roll * 180 / .pi
            newData.gy = gyro.attitude.pitch * 180 / .pi
            newData.gz = gyro.attitude.yaw * 180 / .pi
        }
        
        print("Update lokalizacji i dodanie nowych danych")
        currentFlightData.append(newData)
    }
}
