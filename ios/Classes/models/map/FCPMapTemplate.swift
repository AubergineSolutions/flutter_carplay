//
// FCPMapTemplate.swift
// flutter_carplay
//
// Created by Pradip Sutariya on 17/04/24.
// Copyright © 2024 Aubergine Solutions Pvt. Ltd. All rights reserved.
//

import CarPlay
import Foundation

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
        _super = mapTemplate
        return mapTemplate
    }
}

@available(iOS 14.0, *)
extension FCPMapTemplate: FCPRootTemplate {}
