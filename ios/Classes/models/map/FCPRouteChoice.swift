//
// FCPRouteChoice.swift
// flutter_carplay
//
// Created by Pradip Sutariya on 19/04/24.
// Copyright © 2024 Aubergine Solutions Pvt. Ltd. All rights reserved.
//

import Foundation
import CarPlay

@available(iOS 14.0, *)
class FCPRouteChoice {
    private(set) var _super: CPRouteChoice?
    private(set) var elementId: String
    private var summaryVariants: [String]
    private var selectionSummaryVariants: [String]
    private var additionalInformationVariants: [String]

    init(obj: [String: Any]) {
        elementId = obj["_elementId"] as! String
        summaryVariants = obj["summaryVariants"] as? [String] ?? []
        selectionSummaryVariants = obj["selectionSummaryVariants"] as? [String] ?? []
        additionalInformationVariants = obj["additionalInformationVariants"] as? [String] ?? []
    }
    
    var get: CPRouteChoice {
        let routeChoice = CPRouteChoice(summaryVariants: summaryVariants, additionalInformationVariants: additionalInformationVariants, selectionSummaryVariants: selectionSummaryVariants)
        _super = routeChoice
        return routeChoice
    }
}
