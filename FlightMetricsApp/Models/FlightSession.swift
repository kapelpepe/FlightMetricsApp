//
//  FlightSession.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 26/10/2025.
//

import Foundation
import CoreData

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
        self.distance = 0 // dystans zostanie policzony w managerze

        self.records = Set(flightRecords)
    }
}
