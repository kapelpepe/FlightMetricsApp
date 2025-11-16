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
    
    // DLA TESTOW - transferFile nie dziala na symulatorze
    
    func sendFlightFileIfPossible(_ fileURL: URL) {
        let session = WCSession.default
        guard session.activationState == .activated else {
            print("WCSession nieaktywna")
            return
        }

        print("WatchSession: transferFile")
        session.transferFile(fileURL, metadata: nil)
    }
    
    /*func sendFlightFileIfPossible(_ fileURL: URL) {
        do {
            let data = try Data(contentsOf: fileURL)
            try WCSession.default.updateApplicationContext(["flightData": data])
            print("Wysylam dane")
        } catch {
            print("Błąd wysyłania danych")
        }
    }*/
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
}
