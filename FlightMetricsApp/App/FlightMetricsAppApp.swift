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
    @AppStorage("colorScheme") private var colorScheme: String = "system" // kolory z Assets
    
    init() {
        _ = PhoneSession.shared
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(
                    colorScheme == "system" ? nil : (colorScheme == "light" ? .light : .dark)
                )
        }
    }
}
