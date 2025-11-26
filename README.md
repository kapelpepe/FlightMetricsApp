# Flight Metrics

🇵🇱 Polish version (English below)

**Flight Metrics** to aplikacja przeznaczona na urządzenia mobilne iOS i watchOS. Służy do monitorowania i analizy parametrów lotów rekreacyjnych. Pozwala na zbieranie dane z czujników zegarka Apple Watch (czujnika GPS, barometru, akcelerometru, żyroskopu, czujnika tętna oraz czujnika natlenienia krwi) oraz ich prezentacji w formie wykresów i statystyk.

---

## Funkcjonalności

- **Rejestrowanie danych lotu na zegarku Apple Watch**  
  - Pozycja GPS, wysokość, prędkość, ciśnienie atmosferyczne.
  - Dane z akcelerometru i żyroskopu (wektory ruchu i obrotu).  
  - Pomiar tętna i saturacji krwi (HealthKit).  

- **Zarządzanie sesjami lotu**  
  - Tworzenie i zapisywanie sesji w bazie lokalnej Core Data.
  - Generowanie trasy lotu na mapie.
  - Automatyczne obliczanie dystansu i czasu lotu.
  - Obliczenie średniej, mediany, wartości minimalnych i maksymalnych dla danych parametrów lotu.

- **Integracja i synchronizacja**  
  - Wsparcie dla komunikacji między iOS a Apple Watch (WatchConnectivity).
  - Automatyczny przesył pliku JSON w momencie połączenia z telefonem (automatyczna synchronizacja danych).

---

## Technologie i frameworki

- **Swift & SwiftUI**
- **WatchConnectivity** 
- **Core Data** 
- **MapKit**
- **CoreLocation & CoreMotion**
- **HealthKit**
- **Charts**
- **XCTest**

---

## Struktura projektu
```
FlightMetricsApp/
├── FlightMetricsApp/ # Kod źródłowy aplikacji iOS
├── FlightMetricsAppTests/ # Testy jednostkowe
├── FlightMetricsAppWatch Watch App/ # Kod źródłowy aplikacji watchOS
├── README.md
```
---

## Instalacja i uruchomienie

1. Sklonuj repozytorium:
    ```bash
    git clone https://github.com/kapelpepe/FlightMetricsApp.git
    ```
2. Otwórz projekt w Xcode (FlightMetricsApp.xcodeproj).

3. Wybierz target iOS lub watchOS i uruchom aplikacje symulatorach lub urządzeniach fizycznych.

Aplikacja wymaga uprawnień do lokalizacji i odczytu danych HealthKit, aby poprawnie rejestrować dane lotu!

## Testy

1. Testy jednostkowe znajdują się w katalogu FlightMetricsAppTests.

2. Testy można uruchomić w Xcode poprzez Product → Test.

🇬🇧 English version

**Flight Metrics** is a mobile application for iOS and watchOS designed to monitor and analyze recreational flight parameters. It collects data from Apple Watch sensors (GPS, barometer, accelerometer, gyroscope, heart rate sensor, blood oxygen sensor) and displays them as charts and statistics on the iPhone.

---

## Features

- **Flight Data Recording**
  - GPS position, altitude, speed, atmospheric pressure.
  - Accelerometer and gyroscope data (motion and rotation vectors).
  - Heart rate and blood oxygen measurement (HealthKit).

- **Flight Session Management**
  - Creating and storing sessions in Core Data.
  - Generating flight routes on a map.
  - Automatic calculation of distance, flight time and statistics.
  - Average, median, minimum, and maximum values for flight parameters.

- **Integration and Synchronization**
  - Support for iOS and Apple Watch communication (WatchConnectivity).

---

## Technologies & frameworks

- **Swift & SwiftUI**
- **WatchConnectivity**
- **Core Data**
- **MapKit**
- **CoreLocation & CoreMotion**
- **HealthKit**
- **Charts**
- **XCTest**

---

## Project Structure
```
FlightMetricsApp/
├── FlightMetricsApp/ # iOS application source code
├── FlightMetricsAppTests/ # Unit tests
├── FlightMetricsAppWatch Watch App/ # watchOS source code
├── README.md
```
---

## Installation and running

1. Clone the repository:
    ```bash
    git clone https://github.com/kapelpepe/FlightMetricsApp.git
    ```
2. Open the project in Xcode (FlightMetricsApp.xcodeproj).

3. Select the iOS or watchOS target and run the app on a simulator or a physical device.

The application requires Location and HealthKit permissions to properly record flight data!

## Tests

1. Unit tests are located in the `FlightMetricsAppTests` directory.

2. You can run the tests in Xcode via Product → Test.

---
