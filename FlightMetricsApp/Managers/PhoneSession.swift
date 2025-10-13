//
//  PhoneSession.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 13/10/2025.
//

import Foundation
import WatchConnectivity

class PhoneSession: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        //funkcja wymagana przez protokol WCSessionDelegate - nieuzywana
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //funkcja wymagana przez protokol WCSessionDelegate - nieuzywana
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //funkcja wymagana przez protokol WCSessionDelegate - nieuzywana
    }
    
    static let shared = PhoneSession()
    var onNumberReceived: ((Int)->Void)?
    
    private override init() {
        super.init()
        if WCSession.isSupported(){
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let num = message["random"] as? Int {
            DispatchQueue.main.async {
                self.onNumberReceived?(num)
            }
        }
    }
}
