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
    var onNumberReceived: ((Int)->Void)?
    
    private override init() {
        super.init()
        if WCSession.isSupported(){
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: (any Error)?) {
    }
}
