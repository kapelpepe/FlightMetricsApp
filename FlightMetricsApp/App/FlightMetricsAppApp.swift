//
//  FlightMetricsAppApp.swift
//  FlightMetricsApp
//
//  Created by Kacper Gwiazda on 04/10/2025.
//

import SwiftUI

@main
struct FlightMetricsAppApp: App {
    
    init() {
        _ = PhoneSession.shared
    }
    
    var body: some Scene {
        WindowGroup {
            PhoneContentView()
        }
    }
}
