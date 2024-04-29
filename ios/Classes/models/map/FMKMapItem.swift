//
// FMKMapItem.swift
// flutter_carplay
//
// Created by Pradip Sutariya on 19/04/24.
// Copyright © 2024 Aubergine Solutions Pvt. Ltd. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

@available(iOS 14.0, *)
class FMKMapItem {
    private(set) var _super: MKMapItem?
    private(set) var elementId: String
    private var latitude: Double
    private var longitude: Double
    private var name: String
    
    init(obj: [String: Any]) {
        elementId = obj["_elementId"] as! String
        latitude = obj["latitude"] as! Double
        longitude = obj["longitude"] as! Double
        name = obj["name"] as! String
    }
    
    var get: MKMapItem {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
        mapItem.name = name
        _super = mapItem
        return mapItem
    }
}
