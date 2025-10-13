//
//  WatchSession.swift
//  FlightMetricsAppWatch Watch App
//
//  Created by Gwiazda, Kacper on 13/10/2025.
//

import Foundation
import WatchConnectivity

class WatchSession: NSObject, WCSessionDelegate {
    
    static let shared = WatchSession()
    
    private override init() {
        super.init()
        if WCSession.isSupported(){
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func sendFlightFileIfPossible(_ fileURL: URL) {
        guard WCSession.default.isReachable else {
            print("Telefon nie zostal znaleziony")
            return
        }
        WCSession.default.transferFile(fileURL, metadata: ["type": "flightData"])
        print("Wysylam dane → \(fileURL.lastPathComponent)")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
}
