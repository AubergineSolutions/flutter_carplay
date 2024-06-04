//
// FCPMapTemplate.swift
// flutter_carplay
//
// Created by Pradip Sutariya on 17/04/24.
// Copyright © 2024 Aubergine Solutions Pvt. Ltd. All rights reserved.
//

import CarPlay

@available(iOS 14.0, *)
class FCPMapTemplate: NSObject {
    private(set) var _super: CPMapTemplate?
    private(set) var elementId: String
    private(set) var objcMapViewController: FCPMapViewController
    private var mapButtons: [CPMapButton]
    private var leadingNavigationBarButtons: [CPBarButton]
    private var trailingNavigationBarButtons: [CPBarButton]
    private var automaticallyHidesNavigationBar: Bool
    private var hidesButtonsWithNavigationBar: Bool
    private var backButton: CPBarButton?
    private var navigationSession: CPNavigationSession?

    init(obj: [String: Any]) {
        elementId = obj["_elementId"] as! String
        mapButtons = (obj["mapButtons"] as! [[String: Any]]).map {
            FCPMapButton(obj: $0).get
        }
        leadingNavigationBarButtons = (obj["leadingNavigationBarButtons"] as? [[String: Any]] ?? []).map {
            FCPBarButton(obj: $0).get
        }
        trailingNavigationBarButtons = (obj["trailingNavigationBarButtons"] as? [[String: Any]] ?? []).map {
            FCPBarButton(obj: $0).get
        }
        automaticallyHidesNavigationBar = obj["automaticallyHidesNavigationBar"] as? Bool ?? true
        hidesButtonsWithNavigationBar = obj["hidesButtonsWithNavigationBar"] as? Bool ?? true
        let backButtonData = obj["backButton"] as? [String: Any]
        if backButtonData != nil {
            backButton = FCPBarButton(obj: backButtonData!).get
        }

        objcMapViewController = FCPMapViewController(nibName: nil, bundle: nil)
    }

    var get: CPMapTemplate {
        let mapTemplate = CPMapTemplate()
        mapTemplate.mapButtons = mapButtons
        mapTemplate.leadingNavigationBarButtons = leadingNavigationBarButtons
        mapTemplate.trailingNavigationBarButtons = trailingNavigationBarButtons
        mapTemplate.automaticallyHidesNavigationBar = automaticallyHidesNavigationBar
        mapTemplate.hidesButtonsWithNavigationBar = hidesButtonsWithNavigationBar
        mapTemplate.backButton = backButton
        mapTemplate.mapDelegate = self
        _super = mapTemplate
        return mapTemplate
    }

    func update(mapButtons: [CPMapButton]?, leadingNavigationBarButtons: [CPBarButton]?, trailingNavigationBarButtons: [CPBarButton]?, automaticallyHidesNavigationBar: Bool?, hidesButtonsWithNavigationBar: Bool?, backButton: CPBarButton?) {
        if let mapButtons = mapButtons {
            _super?.mapButtons = mapButtons
            self.mapButtons = mapButtons
        }
        if let leadingNavigationBarButtons = leadingNavigationBarButtons {
            _super?.leadingNavigationBarButtons = leadingNavigationBarButtons
            self.leadingNavigationBarButtons = leadingNavigationBarButtons
        }
        if let trailingNavigationBarButtons = trailingNavigationBarButtons {
            _super?.trailingNavigationBarButtons = trailingNavigationBarButtons
            self.trailingNavigationBarButtons = trailingNavigationBarButtons
        }
        if let automaticallyHidesNavigationBar = automaticallyHidesNavigationBar {
            _super?.automaticallyHidesNavigationBar = automaticallyHidesNavigationBar
            self.automaticallyHidesNavigationBar = automaticallyHidesNavigationBar
        }
        if let hidesButtonsWithNavigationBar = hidesButtonsWithNavigationBar {
            _super?.hidesButtonsWithNavigationBar = hidesButtonsWithNavigationBar
            self.hidesButtonsWithNavigationBar = hidesButtonsWithNavigationBar
        }
        if let backButton = backButton {
            _super?.backButton = backButton
            self.backButton = backButton
        }
    }
}

// MARK: - Map Template Methods

extension FCPMapTemplate {
    
    func showTripPreviews(_ tripPreviews: [FCPTrip], selectedTrip: FCPTrip?, textConfiguration: FCPTripPreviewTextConfiguration?) {
        _super?.showTripPreviews(tripPreviews.map { $0.get }, selectedTrip: selectedTrip?.get, textConfiguration: textConfiguration?.get)

        // Add polyline overlay
        if let origin = selectedTrip?.getOrigin(), let destination = selectedTrip?.getDestination() {
            objcMapViewController.showRouteOnMap(sourceMapItem: origin, destinationMapItem: destination)
        }
    }

    func hideTripPreviews() {
        _super?.hideTripPreviews()
    }

    func showPanningInterface(animated: Bool) {
        _super?.showPanningInterface(animated: animated)
    }

    func dismissPanningInterface(animated: Bool) {
        _super?.dismissPanningInterface(animated: animated)
    }
    
    func zoomInMapView(animated: Bool) {
        objcMapViewController.zoomInMapView(animated: animated)
    }
    
    func zoomOutMapView(animated: Bool) {
        objcMapViewController.zoomOutMapView(animated: animated)
    }
    
    func moveToCurrentLocation(animated: Bool){
        objcMapViewController.moveToCurrentLocation(animated: animated)
    }
}

// MARK: - Map Template Delegate
extension FCPMapTemplate: CPMapTemplateDelegate {
    
    func mapTemplate(_: CPMapTemplate, panWith direction: CPMapTemplate.PanDirection) {
        objcMapViewController.panInDirection(direction)
    }
    
    func mapTemplate(_ mapTemplate: CPMapTemplate, startedTrip trip: CPTrip, using routeChoice: CPRouteChoice) {

        hideTripPreviews()
        let navSession = mapTemplate.startNavigationSession(for: trip)
        if #available(iOS 15.4, *) {
            navSession.pauseTrip(for: .loading, description: "Loading", turnCardColor: .green)
        } else {
            // Fallback on earlier versions
        }
        navigationSession = navSession
        
        if let route = objcMapViewController.getCurrentRoute(),
          let step = route.steps.first {
            
            let cpManeuver = CPManeuver()
            let estimates = CPTravelEstimates(distanceRemaining: Measurement(value: step.distance, unit: UnitLength.meters), timeRemaining: 300)
            cpManeuver.initialTravelEstimates = estimates
            cpManeuver.instructionVariants = [step.instructions]
            
            navSession.upcomingManeuvers = [cpManeuver]
            
            
        }
        
    }
}

@available(iOS 14.0, *)
extension FCPMapTemplate: FCPRootTemplate {}

extension FCPMapTemplate: ElementIdentifiable {}
