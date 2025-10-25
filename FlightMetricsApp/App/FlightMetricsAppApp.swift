//
//  FlightMetricsAppApp.swift
//  FlightMetricsApp
//
//  Created by Kacper Gwiazda on 04/10/2025.
//

import SwiftUI

@main
struct FlightMetricsAppApp: App {
    
    let persistenceController = PersistenceController.shared
    
    init() {
        _ = PhoneSession.shared
    }
    
    var body: some Scene {
        WindowGroup {
            PhoneContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
