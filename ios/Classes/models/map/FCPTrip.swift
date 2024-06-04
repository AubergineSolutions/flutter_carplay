//
// FCPTrip.swift
// flutter_carplay
//
// Created by Pradip Sutariya on 19/04/24.
// Copyright © 2024 Aubergine Solutions Pvt. Ltd. All rights reserved.
//

import CarPlay

@available(iOS 14.0, *)
class FCPTrip {
    private(set) var _super: CPTrip?
    private(set) var elementId: String
    private var origin: MKMapItem
    private var destination: MKMapItem
    private var routeChoices: [CPRouteChoice]

    init(obj: [String: Any]) {
        elementId = obj["_elementId"] as! String
        origin = FMKMapItem(obj: obj["origin"] as! [String: Any]).get
        destination = FMKMapItem(obj: obj["destination"] as! [String: Any]).get
        routeChoices = (obj["routeChoices"] as! [[String: Any]]).map {
            FCPRouteChoice(obj: $0).get
        }
    }

    var get: CPTrip {
        let trip = CPTrip(origin: origin, destination: destination, routeChoices: routeChoices)
        _super = trip
        return trip
    }

    func getOrigin() -> MKMapItem {
        return origin
    }

    func getDestination() -> MKMapItem {
        return destination
    }

    func getOriginCoordinate() -> CLLocationCoordinate2D {
        return origin.placemark.coordinate
    }

    func getDestinationCoordinate() -> CLLocationCoordinate2D {
        return origin.placemark.coordinate
    }
}
