//
//  FlightRecord.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 25/10/2025.
//

import Foundation
import CoreData

@objc(FlightRecord)
public class FlightRecord: NSManagedObject {

}

extension FlightRecord {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlightRecord> {
        return NSFetchRequest<FlightRecord>(entityName: "FlightRecord")
    }

    @NSManaged public var timestamp: Date
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var altitudeMeters: Double
    @NSManaged public var speedKnots: Double
    @NSManaged public var pressure: Double
    @NSManaged public var relativeAltitude: Double
    @NSManaged public var heartRateBPM: Double
    @NSManaged public var ax: Double
    @NSManaged public var ay: Double
    @NSManaged public var az: Double
    @NSManaged public var gx: Double
    @NSManaged public var gy: Double
    @NSManaged public var gz: Double
    
    convenience init(from flightData: FlightData, context: NSManagedObjectContext) {
        self.init(context: context)
        self.timestamp = flightData.timestamp
        self.latitude = flightData.latitude
        self.longitude = flightData.longitude
        self.altitudeMeters = flightData.altitudeMeters
        self.speedKnots = flightData.speedKnots
        self.pressure = flightData.pressure ?? 0
        self.relativeAltitude = flightData.relativeAltitude ?? 0
        self.heartRateBPM = flightData.heartRateBPM ?? 0
        self.ax = flightData.ax ?? 0
        self.ay = flightData.ay ?? 0
        self.az = flightData.az ?? 0
        self.gx = flightData.gx ?? 0
        self.gy = flightData.gy ?? 0
        self.gz = flightData.gz ?? 0
    }
}
