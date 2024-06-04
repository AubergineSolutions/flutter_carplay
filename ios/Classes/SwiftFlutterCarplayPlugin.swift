//
//  SwiftFlutterCarplayPlugin.swift
//  flutter_carplay
//
//  Created by Oğuzhan Atalay on 21.08.2021.
//

import CarPlay
import Flutter

@available(iOS 14.0, *)
public class SwiftFlutterCarplayPlugin: NSObject, FlutterPlugin {
    private static var streamHandler: FCPStreamHandlerPlugin?
    private(set) static var registrar: FlutterPluginRegistrar?
    private static var objcRootTemplate: FCPRootTemplate?
    private static var _rootTemplate: CPTemplate?
    private static var _objcMapViewController: FCPMapViewController?

    public static var animated: Bool = false
    private var objcPresentTemplate: FCPPresentTemplate?

    public static var rootTemplate: CPTemplate? {
        get {
            return _rootTemplate
        }
        set(tabBarTemplate) {
            _rootTemplate = tabBarTemplate
        }
    }

    static var objcMapViewController: FCPMapViewController? {
        get {
            return _objcMapViewController
        }
        set(viewController) {
            _objcMapViewController = viewController
        }
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: makeFCPChannelId(event: ""),
                                           binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCarplayPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        self.registrar = registrar

        streamHandler = FCPStreamHandlerPlugin(registrar: registrar)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case FCPChannelTypes.setRootTemplate:
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            var rootTemplate: FCPRootTemplate?
            switch args["runtimeType"] as! String {
            case String(describing: FCPTabBarTemplate.self):
                rootTemplate = FCPTabBarTemplate(obj: args["rootTemplate"] as! [String: Any])
                if (rootTemplate as! FCPTabBarTemplate).getTemplates().count > 5 {
                    result(FlutterError(code: "ERROR",
                                        message: "CarPlay cannot have more than 5 templates on one screen.",
                                        details: nil))
                    return
                }
                SwiftFlutterCarplayPlugin.rootTemplate = (rootTemplate as! FCPTabBarTemplate).get
            case String(describing: FCPGridTemplate.self):
                rootTemplate = FCPGridTemplate(obj: args["rootTemplate"] as! [String: Any])
                SwiftFlutterCarplayPlugin.rootTemplate = (rootTemplate as! FCPGridTemplate).get
            case String(describing: FCPInformationTemplate.self):
                rootTemplate = FCPInformationTemplate(obj: args["rootTemplate"] as! [String: Any])
                SwiftFlutterCarplayPlugin.rootTemplate = (rootTemplate as! FCPInformationTemplate).get
            case String(describing: FCPPointOfInterestTemplate.self):
                rootTemplate = FCPPointOfInterestTemplate(obj: args["rootTemplate"] as! [String: Any])
                SwiftFlutterCarplayPlugin.rootTemplate = (rootTemplate as! FCPPointOfInterestTemplate).get
            case String(describing: FCPListTemplate.self):
                rootTemplate = FCPListTemplate(obj: args["rootTemplate"] as! [String: Any], templateType: FCPListTemplateTypes.DEFAULT)
                SwiftFlutterCarplayPlugin.rootTemplate = (rootTemplate as! FCPListTemplate).get
            case String(describing: FCPMapTemplate.self):
                rootTemplate = FCPMapTemplate(obj: args["rootTemplate"] as! [String: Any])
                SwiftFlutterCarplayPlugin.rootTemplate = (rootTemplate as! FCPMapTemplate).get
                SwiftFlutterCarplayPlugin.objcMapViewController = (rootTemplate as! FCPMapTemplate).objcMapViewController
            default:
                result(false)
                return
            }
            SwiftFlutterCarplayPlugin.objcRootTemplate = rootTemplate
            let animated = args["animated"] as! Bool
            SwiftFlutterCarplayPlugin.animated = animated
            result(true)
        case FCPChannelTypes.forceUpdateRootTemplate:
            FlutterCarPlaySceneDelegate.forceUpdateRootTemplate()
            result(true)
        case FCPChannelTypes.updateListItem:
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            let elementId = args["_elementId"] as! String
            let text = args["text"] as? String
            let detailText = args["detailText"] as? String
            let image = args["image"] as? String
            let playbackProgress = args["playbackProgress"] as? CGFloat
            let isPlaying = args["isPlaying"] as? Bool
            let playingIndicatorLocation = args["playingIndicatorLocation"] as? String
            let accessoryType = args["accessoryType"] as? String
            SwiftFlutterCarplayPlugin.findItem(elementId: elementId, actionWhenFound: { item in
                item.update(text: text, detailText: detailText, image: image, playbackProgress: playbackProgress, isPlaying: isPlaying, playingIndicatorLocation: playingIndicatorLocation, accessoryType: accessoryType)
            })
            result(true)
        case FCPChannelTypes.onListItemSelectedComplete:
            guard let args = call.arguments as? String else {
                result(false)
                return
            }
            SwiftFlutterCarplayPlugin.findItem(elementId: args, actionWhenFound: { item in
                item.stopHandler()
            })
            result(true)
        case FCPChannelTypes.setAlert:
            guard objcPresentTemplate == nil else {
                result(FlutterError(code: "ERROR",
                                    message: "CarPlay can only present one modal template at a time.",
                                    details: nil))
                return
            }
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            let alertTemplate = FCPAlertTemplate(obj: args["rootTemplate"] as! [String: Any])
            objcPresentTemplate = alertTemplate
            let animated = args["animated"] as! Bool
            FlutterCarPlaySceneDelegate
                .presentTemplate(template: alertTemplate.get, animated: animated, onPresent: { completed in
                    FCPStreamHandlerPlugin.sendEvent(type: FCPChannelTypes.onPresentStateChanged,
                                                     data: ["completed": completed])
                })
            result(true)
        case FCPChannelTypes.setActionSheet:
            guard objcPresentTemplate == nil else {
                result(FlutterError(code: "ERROR",
                                    message: "CarPlay can only present one modal template at a time.",
                                    details: nil))
                return
            }
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            let actionSheetTemplate = FCPActionSheetTemplate(obj: args["rootTemplate"] as! [String: Any])
            objcPresentTemplate = actionSheetTemplate
            let animated = args["animated"] as! Bool
            FlutterCarPlaySceneDelegate.presentTemplate(template: actionSheetTemplate.get, animated: animated, onPresent: { _ in })
            result(true)
        case FCPChannelTypes.popTemplate:
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            for _ in 1 ... (args["count"] as! Int) {
                FlutterCarPlaySceneDelegate.pop(animated: args["animated"] as! Bool)
            }
            result(true)
        case FCPChannelTypes.closePresent:
            guard let animated = call.arguments as? Bool else {
                result(false)
                return
            }
            FlutterCarPlaySceneDelegate.closePresent(animated: animated)
            objcPresentTemplate = nil
            result(true)
        case FCPChannelTypes.pushTemplate:
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            var pushTemplate: CPTemplate?
            let animated = args["animated"] as! Bool
            switch args["runtimeType"] as! String {
            case String(describing: FCPGridTemplate.self):
                pushTemplate = FCPGridTemplate(obj: args["template"] as! [String: Any]).get
            case String(describing: FCPPointOfInterestTemplate.self):
                pushTemplate = FCPPointOfInterestTemplate(obj: args["template"] as! [String: Any]).get
            case String(describing: FCPInformationTemplate.self):
                pushTemplate = FCPInformationTemplate(obj: args["template"] as! [String: Any]).get
            case String(describing: FCPListTemplate.self):
                pushTemplate = FCPListTemplate(obj: args["template"] as! [String: Any], templateType: FCPListTemplateTypes.DEFAULT).get
            default:
                result(false)
                return
            }
            FlutterCarPlaySceneDelegate.push(template: pushTemplate!, animated: animated)
            result(true)
        case FCPChannelTypes.popToRootTemplate:
            guard let animated = call.arguments as? Bool else {
                result(false)
                return
            }
            FlutterCarPlaySceneDelegate.popToRootTemplate(animated: animated)
            objcPresentTemplate = nil
            result(true)

        case FCPChannelTypes.showTripPreviews:
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            let elementId = args["_elementId"] as! String
            let tripPreviews = (args["tripPreviews"] as! [[String: Any]]).map { FCPTrip(obj: $0) }

            let argsSelectedTrip = args["selectedTrip"] as? [String: Any]
            let selectedTrip = argsSelectedTrip != nil ? FCPTrip(obj: argsSelectedTrip!) : nil

            let argsTextConfiguration = args["textConfiguration"] as? [String: Any]
            let textConfiguration = argsTextConfiguration != nil ? FCPTripPreviewTextConfiguration(obj: argsTextConfiguration!) : nil

            // Define a closure to handle the found template
            let action: (_ template: FCPMapTemplate) -> Void = { template in
                // Handle the found template here
                print("Found template with elementId: \(template.elementId)")
                template.showTripPreviews(tripPreviews, selectedTrip: selectedTrip, textConfiguration: textConfiguration)
            }

            // Call the findTemplate method with the elementId and action closure
            SwiftFlutterCarplayPlugin.findTemplate(elementId: elementId, actionWhenFound: action)
            result(true)

        case FCPChannelTypes.hideTripPreviews:
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            let elementId = args["_elementId"] as! String

            // Define a closure to handle the found template
            let action: (_ template: FCPMapTemplate) -> Void = { template in
                // Handle the found template here
                print("Found template with elementId: \(template.elementId)")
                template.hideTripPreviews()
            }
            SwiftFlutterCarplayPlugin.findTemplate(elementId: elementId, actionWhenFound: action)
            result(true)

        case FCPChannelTypes.showPanningInterface:
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            let elementId = args["_elementId"] as! String
            let animated = args["animated"] as! Bool

            // Define a closure to handle the found template
            let action: (_ template: FCPMapTemplate) -> Void = { template in
                // Handle the found template here
                print("Found template with elementId: \(template.elementId)")
                template.showPanningInterface(animated: animated)
            }
            SwiftFlutterCarplayPlugin.findTemplate(elementId: elementId, actionWhenFound: action)
            result(true)

        case FCPChannelTypes.dismissPanningInterface:
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            let elementId = args["_elementId"] as! String
            let animated = args["animated"] as! Bool

            // Define a closure to handle the found template
            let action: (_ template: FCPMapTemplate) -> Void = { template in
                // Handle the found template here
                print("Found template with elementId: \(template.elementId)")
                template.dismissPanningInterface(animated: animated)
            }
            SwiftFlutterCarplayPlugin.findTemplate(elementId: elementId, actionWhenFound: action)
            result(true)

        case FCPChannelTypes.updateMapTemplate:
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            let elementId = args["_elementId"] as! String

            let mapButtons = (args["mapButtons"] as? [[String: Any]] ?? []).map {
                FCPMapButton(obj: $0).get
            }
            let leadingNavigationBarButtons = (args["leadingNavigationBarButtons"] as? [[String: Any]] ?? []).map {
                FCPBarButton(obj: $0).get
            }
            let trailingNavigationBarButtons = (args["trailingNavigationBarButtons"] as? [[String: Any]] ?? []).map {
                FCPBarButton(obj: $0).get
            }
            let automaticallyHidesNavigationBar = args["automaticallyHidesNavigationBar"] as? Bool
            let hidesButtonsWithNavigationBar = args["hidesButtonsWithNavigationBar"] as? Bool
            let backButtonData = args["backButton"] as? [String: Any]
            let backButton = backButtonData != nil ? FCPBarButton(obj: backButtonData!).get : nil

            // Define a closure to handle the found template
            let action: (_ template: FCPMapTemplate) -> Void = { template in
                // Handle the found template here
                print("Found template with elementId: \(template.elementId)")
                template.update(mapButtons: mapButtons, leadingNavigationBarButtons: leadingNavigationBarButtons, trailingNavigationBarButtons: trailingNavigationBarButtons, automaticallyHidesNavigationBar: automaticallyHidesNavigationBar, hidesButtonsWithNavigationBar: hidesButtonsWithNavigationBar, backButton: backButton)
            }
            SwiftFlutterCarplayPlugin.findTemplate(elementId: elementId, actionWhenFound: action)
            result(true)
        
        case FCPChannelTypes.zoomInMapView:
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            let elementId = args["_elementId"] as! String
            let animated = args["animated"] as! Bool
            
            // Define a closure to handle the found template
            let action: (_ template: FCPMapTemplate) -> Void = { template in
                // Handle the found template here
                print("Found template with elementId: \(template.elementId)")
                template.zoomInMapView(animated: animated)
            }
            SwiftFlutterCarplayPlugin.findTemplate(elementId: elementId, actionWhenFound: action)
            result(true)
            
        case FCPChannelTypes.zoomOutMapView:
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            let elementId = args["_elementId"] as! String
            let animated = args["animated"] as! Bool
            
            // Define a closure to handle the found template
            let action: (_ template: FCPMapTemplate) -> Void = { template in
                // Handle the found template here
                print("Found template with elementId: \(template.elementId)")
                template.zoomOutMapView(animated: animated)
            }
            SwiftFlutterCarplayPlugin.findTemplate(elementId: elementId, actionWhenFound: action)
            result(true)
        case FCPChannelTypes.moveToCurrentLocation:
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            let elementId = args["_elementId"] as! String
            let animated = args["animated"] as! Bool
            
            // Define a closure to handle the found template
            let action: (_ template: FCPMapTemplate) -> Void = { template in
                // Handle the found template here
                print("Found template with elementId: \(template.elementId)")
                template.moveToCurrentLocation(animated: animated)
            }
            SwiftFlutterCarplayPlugin.findTemplate(elementId: elementId, actionWhenFound: action)
            result(true)
        default:
            result(false)
        }
    }

    static func createEventChannel(event: String?) -> FlutterEventChannel {
        let eventChannel = FlutterEventChannel(name: makeFCPChannelId(event: event),
                                               binaryMessenger: SwiftFlutterCarplayPlugin.registrar!.messenger())
        return eventChannel
    }

    static func onCarplayConnectionChange(status: String) {
        FCPStreamHandlerPlugin.sendEvent(type: FCPChannelTypes.onCarplayConnectionChange,
                                         data: ["status": status])
    }

    static func findItem(elementId: String, actionWhenFound: (_ item: FCPListItem) -> Void) {
        print("objcRootTemplate \(String(describing: SwiftFlutterCarplayPlugin.objcRootTemplate))")
        let objcRootTemplateType = String(describing: SwiftFlutterCarplayPlugin.objcRootTemplate).match(#"(.*flutter_carplay\.(.*)\))"#)[0][2]
        print("objcRootTemplateType \(objcRootTemplateType)")
        var templates: [FCPListTemplate] = []
        if objcRootTemplateType.elementsEqual(String(describing: FCPListTemplate.self)) {
            templates.append(SwiftFlutterCarplayPlugin.objcRootTemplate as! FCPListTemplate)
        } else if objcRootTemplateType.elementsEqual(String(describing: FCPTabBarTemplate.self)) {
            templates = (SwiftFlutterCarplayPlugin.objcRootTemplate as! FCPTabBarTemplate).getTemplates()
        } else {
            return
        }
        l1: for t in templates {
            for s in t.getSections() {
                for i in s.getItems() {
                    if i.elementId == elementId {
                        actionWhenFound(i)
                        break l1
                    }
                }
            }
        }
    }

    static func findTemplate<T: ElementIdentifiable>(elementId: String, actionWhenFound: (_ template: T) -> Void) {
        print("objcRootTemplate \(String(describing: SwiftFlutterCarplayPlugin.objcRootTemplate))")

        let objcRootTemplateType = String(describing: SwiftFlutterCarplayPlugin.objcRootTemplate).match(#"(<|\()\s*flutter_carplay\.([^\s.:]+)\b.*?(?=>|\))"#)[0][2]

        print("objcRootTemplateType \(objcRootTemplateType)")

        var templates: [T] = []
        if objcRootTemplateType.elementsEqual(String(describing: T.self)) {
            templates.append(SwiftFlutterCarplayPlugin.objcRootTemplate as! T)
        } else if objcRootTemplateType.elementsEqual(String(describing: FCPTabBarTemplate.self)) {
            let tabBarTemplate = SwiftFlutterCarplayPlugin.objcRootTemplate as! FCPTabBarTemplate
            for t in tabBarTemplate.getTemplates() {
                if t.elementId == elementId {
                    templates.append(SwiftFlutterCarplayPlugin.objcRootTemplate as! T)
                    break
                }
            }
        }

        for t in templates where t.elementId == elementId {
            actionWhenFound(t)
            break
        }
    }
}
