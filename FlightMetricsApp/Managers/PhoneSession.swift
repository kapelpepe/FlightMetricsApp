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
    var onFlightDataReceived: (([FlightData])->Void)?
    
    private override init() {
        super.init()
        if WCSession.isSupported(){
            WCSession.default.delegate = self
            WCSession.default.activate()
            print("PhoneSession: WCSession aktywowany") // testowy print
        }
    }
    
    // DLA TESTOW - funkcja z didReceive file niestety nie dziala na symulatorze. Poki nie prowadze testow na urzadzeniu fizycznym, wykorzystuje przebudowana session z didReceiveApplicationContext
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
     
     print("PhoneSession: mam plik \(file.fileURL.lastPathComponent)")
     
     let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
     .appendingPathComponent(file.fileURL.lastPathComponent)
     
     do {
     try FileManager.default.copyItem(at: file.fileURL, to: destinationURL)
     print("Zapisano plik")
     
     let data = try Data(contentsOf: destinationURL) // dekodowanie jsona
     let decoder = JSONDecoder()
     let flightData = try decoder.decode([FlightData].self, from: data)
     
     DispatchQueue.main.async {
     self.onFlightDataReceived?(flightData)
     }
     
     } catch {
     print("Błąd w odbiorze pliku")
     }
     }
    
    /*func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let data = applicationContext["flightData"] as? Data {
            let decoder = JSONDecoder()
            if let flights = try? decoder.decode([FlightData].self, from: data) {
                print("Odebrano \(flights.count) rekordów JSON")
                
                DispatchQueue.main.async {
                    self.onFlightDataReceived?(flights)
                }
            }
        }
    }*/
    
}
