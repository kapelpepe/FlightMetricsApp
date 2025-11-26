//
//  FlightMetricsAppTests.swift
//  FlightMetricsAppTests
//
//  Created by Kacper Gwiazda on 04/10/2025.
//

import XCTest
@testable import FlightMetricsApp
import CoreLocation

final class FlightMetricsAppTests: XCTestCase {
    
    // TESTY FlightSessionManager
    
    func testFormattedDistance() {
        XCTAssertEqual(FlightSessionManager.formattedDistance(0.05), "50 m")
        XCTAssertEqual(FlightSessionManager.formattedDistance(1.234), "1.2 km")
    }
    
    func testFormattedFlightTime() {
        XCTAssertEqual(FlightSessionManager.formattedFlightTime(3661), "1 h 1 min")
        XCTAssertEqual(FlightSessionManager.formattedFlightTime(61), "1 min 1 s")
        XCTAssertEqual(FlightSessionManager.formattedFlightTime(10), "10 s")
    }
    
    func testFlightSessionManagerWithMockData() throws {
        
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext
        
        let mockLocation1 = CLLocation(latitude: 52.2297, longitude: 21.0122) // MOCK
        var firstData = FlightData(from: mockLocation1)
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
        firstData.flightType = "Lot rekreacyjny"
        
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
        secondData.flightType = "Lot rekreacyjny"

        let record1 = FlightRecord(from: firstData, context: context) // konwersja na rekordy
        let record2 = FlightRecord(from: secondData, context: context)
        
        let session = FlightSessionManager.shared.createSession(from: [record1, record2], context: context) // stworzenie testowej sesji
        
        XCTAssertEqual(session.records?.count, 2)
        XCTAssertEqual(session.flightType, "Lot rekreacyjny")
        XCTAssertGreaterThan(session.distance, 0)
        XCTAssertEqual(session.flightTime, secondData.timestamp.timeIntervalSince(firstData.timestamp))
        
        let speeds = session.records?.map { $0.speedKnots } ?? []
        XCTAssertEqual(FlightStatsManager.average(of: speeds), 15)
        XCTAssertEqual(FlightStatsManager.median(of: speeds), 15)
        XCTAssertEqual(FlightStatsManager.minValue(of: speeds), 10)
        XCTAssertEqual(FlightStatsManager.maxValue(of: speeds), 20)
    }
    
    // TESTY FlightStatsManager
    
    func testAverage() {
        XCTAssertEqual(FlightStatsManager.average(of: [1, 2, 3]), 2)
        XCTAssertEqual(FlightStatsManager.average(of: [-0.49, 0.5]), 0.0) // zakres zera
        XCTAssertNil(FlightStatsManager.average(of: []))
    }
    
    func testMedian() {
        XCTAssertEqual(FlightStatsManager.median(of: [1, 3, 5]), 3)
        XCTAssertEqual(FlightStatsManager.median(of: [0.3, 0.2, 0.1, 0.15]), 0.175)
        XCTAssertEqual(FlightStatsManager.median(of: [0.5, -0.2]), 0.15)
        XCTAssertNil(FlightStatsManager.median(of: []))
    }
    
    func testMinValue() {
        XCTAssertEqual(FlightStatsManager.minValue(of: [3, 1, 8]), 1)
        XCTAssertEqual(FlightStatsManager.minValue(of: [0.02, -0.01]), 0.0)
        XCTAssertNil(FlightStatsManager.minValue(of: [Double.nan]))
    }
    
    func testMaxValue() {
        XCTAssertEqual(FlightStatsManager.maxValue(of: [3, 1, 8]), 8)
        XCTAssertEqual(FlightStatsManager.maxValue(of: [0.02, -0.01]), 0.0)
        XCTAssertNil(FlightStatsManager.maxValue(of: [Double.nan]))
    }
}
