//
// FCPMapViewController.swift
// flutter_carplay
//
// Created by Pradip Sutariya on 19/04/24.
// Copyright © 2024 Aubergine Solutions Pvt. Ltd. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit
import CarPlay

class FCPMapViewController: UIViewController {
    // MARK: - Properties
    
    private var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.overrideUserInterfaceStyle = .light
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        return mapView
    }()
    
    private var locationManager = CLLocationManager()
    private let zoomMultiplier: Double = 1.7
    private var currentRoute: MKRoute?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        startUpdatingLocation()
    }
    
    // MARK: - Setup
    
    private func setupMapView() {
        mapView.delegate = self
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // MARK: - Location Manager
    
    private func startUpdatingLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}

// MARK: - Public Methods

extension FCPMapViewController {
    func getCurrentRoute() -> MKRoute? {
        return currentRoute
    }
    
    func addPolylineOverlay(with coordinates: [CLLocationCoordinate2D]) {
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
    }
    
    func showRouteOnMap(sourceMapItem: MKMapItem, destinationMapItem: MKMapItem) {
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourceMapItem.placemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationMapItem.placemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        mapView.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            response, error in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.currentRoute = route
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    
    func zoomInMapView(animated: Bool) {
        let span = MKCoordinateSpan(
            latitudeDelta: mapView.region.span.latitudeDelta / zoomMultiplier,
            longitudeDelta: mapView.region.span.longitudeDelta / zoomMultiplier
        )
        let region = MKCoordinateRegion(center: mapView.region.center, span: span)
        mapView.setRegion(region, animated: animated)
    }
    
    func zoomOutMapView(animated: Bool) {
        let span = MKCoordinateSpan(
            latitudeDelta: mapView.region.span.latitudeDelta * zoomMultiplier,
            longitudeDelta: mapView.region.span.longitudeDelta * zoomMultiplier
        )
        let region = MKCoordinateRegion(center: mapView.region.center, span: span)
        mapView.setRegion(region, animated: animated)
    }
    
    func moveToCurrentLocation(animated: Bool) {
        let currentLocation = mapView.userLocation.coordinate
        moveTo(coordinates: currentLocation, animated: animated)
    }
    
    
    func panInDirection(_ direction: CPMapTemplate.PanDirection) {
        
        switch direction {
        case .down:
            moveTo(latitudeChange: -getMoveDistance())
        case .up:
            moveTo(latitudeChange: getMoveDistance())
        case .left:
            moveTo(longitudeChange: -getMoveDistance())
        case .right:
            moveTo(longitudeChange: getMoveDistance())
        default:
            break
        }
        
    }
    
    private func moveTo(latitudeChange: Double = 0, longitudeChange: Double = 0) {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: mapView.region.center.latitude + latitudeChange,
                longitude: mapView.region.center.longitude + longitudeChange
            ),
            span: mapView.region.span
        )
        mapView.setRegion(region, animated: true)
    }
    
    private func moveTo(coordinates: CLLocationCoordinate2D, animated: Bool) {
        let zoom: CLLocationDegrees = 0.03
        let region = MKCoordinateRegion(
            center: coordinates,
            span: MKCoordinateSpan(
                latitudeDelta: zoom,
                longitudeDelta: zoom
            )
        )
        mapView.setRegion(region, animated: animated)
    }
    
    private func getMoveDistance() -> CLLocationDistance {
        return mapView.region.span.longitudeDelta / 3.5
    }
}

// MARK: - MKMapViewDelegate

extension FCPMapViewController: MKMapViewDelegate {
    // Implement MKMapViewDelegate methods here if needed
    func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case let polyline as MKPolyline:
            
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .red
            renderer.lineWidth = 5
            return renderer
            
        default:
            fatalError("Unexpected MKOverlay type")
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension FCPMapViewController: CLLocationManagerDelegate {
    // Implement CLLocationManagerDelegate methods here if needed
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location permission granted")
            startUpdatingLocation()
        case .denied, .restricted:
            print("Location permission denied")
            // Handle denied permission
        case .notDetermined:
            print("Location permission not determined")
            // Handle not determined permission
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Current location: \(location)")
        // Handle updated location
    }
    
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        // Handle location manager error
    }
}
