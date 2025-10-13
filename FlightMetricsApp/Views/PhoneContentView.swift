//
//  PhoneContentView.swift
//  FlightMetricsApp
//
//  Created by Kacper Gwiazda on 04/10/2025.
//

import SwiftUI
import WatchConnectivity

struct PhoneContentView: View {
    @State private var receivedNumber: Int? = nil
    
    var body: some View {
        VStack {
            Text("Odebrany numerek:")
                .bold()
            if let number = receivedNumber {
                Text("\(number)")
            } else {
                Text("Brak numerka, wygeneruj przez zegarek")
            }
        }
        .padding()
        .onAppear {
            PhoneSession.shared.onNumberReceived = {
                number in receivedNumber = number
            }
        }
    }
}

#Preview {
    PhoneContentView()
}
