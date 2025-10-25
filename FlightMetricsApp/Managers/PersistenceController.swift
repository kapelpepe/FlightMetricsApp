//
//  PersistenceController.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 25/10/2025.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FlightMetricsApp")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if (error as NSError?) != nil {
                fatalError("Błąd Core Data")
            }
        }
    }
}
