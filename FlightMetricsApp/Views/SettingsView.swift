//
//  SettingsView.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 10/11/2025.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    
    @AppStorage("colorScheme") private var colorScheme: String = "system" // kolory z Assets
    
    private var appVersion: String { // pobieranie wersji i builda
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Ustawienia")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.appFirstAccent)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    Form {
                        Section(header: Text("Wygląd")) {
                            Picker("Tryb kolorów", selection: $colorScheme) {
                                Text("Systemowy").tag("system")
                                Text("Jasny").tag("light")
                                Text("Ciemny").tag("dark")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        Section(header: Text("O aplikacji")) {
                            HStack {
                                Text("Wersja")
                                Spacer()
                                Text("\(appVersion) (build \(buildNumber))")
                                    .foregroundColor(.textSecondary)
                            }
                            
                            HStack {
                                Text("Autor")
                                Spacer()
                                Text("Kacper Gwiazda")
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.appBackground)
                }
            }
        }
        .preferredColorScheme(colorScheme == "system" ? nil : (colorScheme == "light" ? .light : .dark))
    }
}
