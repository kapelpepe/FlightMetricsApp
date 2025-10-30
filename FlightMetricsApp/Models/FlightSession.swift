//
//  FlightSession.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 26/10/2025.
//

import Foundation
import CoreData
import MapKit

@objc(FlightSession)
public class FlightSession: NSManagedObject {}

extension FlightSession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlightSession> {
        return NSFetchRequest<FlightSession>(entityName: "FlightSession")
    }

    @NSManaged public var id: UUID
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var distance: Double
    @NSManaged public var flightTime: Double
    @NSManaged public var records: Set<FlightRecord>?

    convenience init(from flightRecords: [FlightRecord], context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = UUID()
        
        guard let first = flightRecords.first, let last = flightRecords.last else { return }

        self.startDate = first.timestamp
        self.endDate = last.timestamp
        self.flightTime = last.timestamp.timeIntervalSince(first.timestamp)
        self.distance = FlightSessionManager.calculateDistance(for: flightRecords)

        self.records = Set(flightRecords)
    }
    
    var routeCoordinates: [CLLocationCoordinate2D] {
        guard let records = records else { return [] }
        return records
            .sorted(by: { $0.timestamp < $1.timestamp })
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }
}
