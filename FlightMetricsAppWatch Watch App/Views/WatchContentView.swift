//
//  WatchContentView.swift
//  FlightMetricsAppWatch Watch App
//
//  Created by Kacper Gwiazda on 04/10/2025.
//

import SwiftUI
import WatchConnectivity

struct WatchContentView: View {
    @State private var isRunning = false
    
    var body: some View {
        VStack {
            Text(isRunning ? "W trakcie lotu" : "Lot zakonczony")
            Button(isRunning ? "STOP" : "START") {
                if isRunning == true {
                    let randomNumber = Int.random(in: 1...100)
                    
                    if WCSession.default.isReachable {
                        WCSession.default.sendMessage(
                            ["random": randomNumber],
                            replyHandler: nil,
                            errorHandler: { error in print("Błąd wysyłania", error.localizedDescription)
                            }
                        )
                    }
                }
                isRunning.toggle()
            }
        }
        .padding()
        .onAppear {
            _ = WatchSession.shared
        }
    }
}

#Preview {
    WatchContentView()
}
