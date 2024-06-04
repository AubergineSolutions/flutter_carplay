//
//  FCPBarButton.swift
//  flutter_carplay
//
//  Created by Oğuzhan Atalay on 25.08.2021.
//

import CarPlay

@available(iOS 14.0, *)
class FCPBarButton {
    private(set) var _super: CPBarButton?
    private(set) var elementId: String
    private var title: String?
    private var image: UIImage?
    private var style: CPBarButtonStyle
    
    init(obj: [String: Any]) {
        elementId = obj["_elementId"] as! String
        title = obj["title"] as? String
        
        if let image = obj["image"] as? String {
            self.image = UIImage().fromFlutterAsset(name: image)
        }
        let style = obj["style"] as? String
        if style == nil || style == "rounded" {
            self.style = CPBarButtonStyle.rounded
        } else {
            self.style = CPBarButtonStyle.none
        }
    }
    
    var get: CPBarButton {
        var barButton: CPBarButton
        if let title = title {
            barButton = CPBarButton(title: title, handler: { _ in
                DispatchQueue.main.async {
                    FCPStreamHandlerPlugin.sendEvent(type: FCPChannelTypes.onBarButtonPressed, data: ["elementId": self.elementId])
                }
            })
        } else if let image = image {
            barButton = CPBarButton(image: image, handler: { _ in
                DispatchQueue.main.async {
                    FCPStreamHandlerPlugin.sendEvent(type: FCPChannelTypes.onBarButtonPressed, data: ["elementId": self.elementId])
                }
            })
        } else {
            barButton = CPBarButton(title: "", handler: nil)
        }
        barButton.buttonStyle = style
        _super = barButton
        return barButton
    }
}
