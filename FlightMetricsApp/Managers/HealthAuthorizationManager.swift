//
//  HealthAuthorizationManager.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 21/11/2025.
//

import Foundation
import HealthKit

class HealthAuthorizationManager {
    static let shared = HealthAuthorizationManager()
    private let healthStore = HKHealthStore()

    private init() { }

    func requestAuthorization() {
        
        guard let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("Brak typu heartRate")
            return
        }
        
        guard let bloodOxygen = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) else {
            print("Brak typu bloodOxygen")
            return
        }

        let toShare: Set<HKSampleType> = [] // pusty blok share; nic nie zapisujemy w danych zdrowotnych; wymagany przez funkcje requestAuth
        
        let toRead: Set<HKObjectType> = [heartRate, bloodOxygen]
        
        healthStore.requestAuthorization(toShare: toShare, read: toRead) { success, error in
            if success {
                print("Uprawnienia HealthKit nadane")
            } else {
                print("Brak uprawnień HealthKit!")
            }
        }
    }
}
