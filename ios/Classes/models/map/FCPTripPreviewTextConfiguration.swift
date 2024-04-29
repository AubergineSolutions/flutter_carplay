//
// FCPTripPreviewTextConfiguration.swift
// flutter_carplay
//
// Created by Pradip Sutariya on 19/04/24.
// Copyright © 2024 Aubergine Solutions Pvt. Ltd. All rights reserved.
//

import Foundation
import CarPlay

@available(iOS 14.0, *)
class FCPTripPreviewTextConfiguration {
    private(set) var _super: CPTripPreviewTextConfiguration?
    private(set) var elementId: String
    private var startButtonTitle: String?
    private var additionalRoutesButtonTitle: String?
    private var overviewButtonTitle: String?
    
    init(obj: [String: Any]) {
        elementId = obj["_elementId"] as! String
        startButtonTitle = obj["startButtonTitle"] as? String
        additionalRoutesButtonTitle = obj["additionalRoutesButtonTitle"] as? String
        overviewButtonTitle = obj["overviewButtonTitle"] as? String
    }
    
    var get: CPTripPreviewTextConfiguration {
        let tripPreviewTextConfiguration = CPTripPreviewTextConfiguration(startButtonTitle: startButtonTitle, additionalRoutesButtonTitle: additionalRoutesButtonTitle, overviewButtonTitle: overviewButtonTitle)
        
        _super = tripPreviewTextConfiguration
        return tripPreviewTextConfiguration
    }
    
    
}
