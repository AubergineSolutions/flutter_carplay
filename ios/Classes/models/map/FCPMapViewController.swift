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

//    private var locationManager = CLLocationManager()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
//        startUpdatingLocation()
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
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
    }
}

// MARK: - MKMapViewDelegate

extension FCPMapViewController: MKMapViewDelegate {
    // Implement MKMapViewDelegate methods here if needed
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
