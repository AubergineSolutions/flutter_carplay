//
// FCPMapButton.swift
// flutter_carplay
//
// Created by Pradip Sutariya on 17/04/24.
// Copyright © 2024 Aubergine Solutions Pvt. Ltd. All rights reserved.
//

import CarPlay
import Foundation

@available(iOS 14.0, *)
class FCPMapButton: NSObject {
    private(set) var _super: CPMapButton?
    private(set) var elementId: String
    private var isEnabled: Bool
    private var isHidden: Bool
    private var image: UIImage?
    private var focusedImage: UIImage?

    init(obj: [String: Any]) {
        elementId = obj["_elementId"] as! String
        isEnabled = obj["isEnabled"] as? Bool ?? true
        isHidden = obj["isHidden"] as? Bool ?? false

        if let image = obj["image"] as? String {
            self.image = UIImage().fromFlutterAsset(name: image)
        }
        if let focusedImage = obj["focusedImage"] as? String {
            self.focusedImage = UIImage().fromFlutterAsset(name: focusedImage)
        }
    }

    var get: CPMapButton {
        let mapButton = CPMapButton(handler: { _ in
            DispatchQueue.main.async {
                FCPStreamHandlerPlugin.sendEvent(type: FCPChannelTypes.onMapButtonPressed,
                                                 data: ["elementId": self.elementId])
            }
        })

        mapButton.isEnabled = isEnabled
        mapButton.isHidden = isHidden
        mapButton.image = image
        mapButton.focusedImage = focusedImage
        return mapButton
    }
}
