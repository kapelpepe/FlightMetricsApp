//
//  FlightMapView.swift
//  FlightMetricsApp
//
//  Created by Gwiazda, Kacper on 30/10/2025.
//

import Foundation
import SwiftUI
import MapKit

struct FlightMapView: UIViewRepresentable {
    var coordinates: [CLLocationCoordinate2D]
    var interactive : Bool = false
    var edgePadding: UIEdgeInsets = .init(top: 50, left: 50, bottom: 50, right: 50)
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.isScrollEnabled = interactive
        mapView.isZoomEnabled = interactive
        mapView.isUserInteractionEnabled = interactive
        mapView.showsUserLocation = false
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        
        guard !coordinates.isEmpty else { return }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count) // rysowanie trasy (polyline)
        uiView.addOverlay(polyline)
        
        if let first = coordinates.first { // pinezki start/meta
            let startPin = MKPointAnnotation()
            startPin.coordinate = first
            startPin.title = "Start"
            uiView.addAnnotation(startPin)
        }
        
        if let last = coordinates.last {
            let endPin = MKPointAnnotation()
            endPin.coordinate = last
            endPin.title = "Koniec"
            uiView.addAnnotation(endPin)
        }
        
        if coordinates.count > 1 {
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            uiView.addOverlay(polyline)

            let rect = polyline.boundingMapRect
            uiView.setVisibleMapRect(
                rect,
                edgePadding: edgePadding,
                animated: true
            )
        } else if let first = coordinates.first {
            uiView.setRegion(
                MKCoordinateRegion(
                    center: first,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ),
                animated: true
            )
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
