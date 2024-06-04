import 'package:flutter/services.dart';
import 'package:flutter_carplay/constants/private_constants.dart';
import 'package:flutter_carplay/flutter_carplay.dart';
import 'package:flutter_carplay/helpers/carplay_helper.dart';

/// [FlutterCarPlayController] is an root object in order to control and communication
/// system with the Apple CarPlay and native functions.
class FlutterCarPlayController {
  static final FlutterCarplayHelper _carplayHelper = FlutterCarplayHelper();
  static final MethodChannel _methodChannel =
      MethodChannel(_carplayHelper.makeFCPChannelId());
  static final EventChannel _eventChannel =
      EventChannel(_carplayHelper.makeFCPChannelId(event: "/event"));

  /// [CPTabBarTemplate], [CPGridTemplate], [CPListTemplate], [CPIInformationTemplate], [CPPointOfInterestTemplate], [CPMapTemplate] in a List
  static List<dynamic> templateHistory = [];

  /// [CPTabBarTemplate], [CPGridTemplate], [CPListTemplate], [CPIInformationTemplate], [CPPointOfInterestTemplate], [CPMapTemplate]
  static dynamic currentRootTemplate;

  /// [CPAlertTemplate], [CPActionSheetTemplate]
  static dynamic currentPresentTemplate;

  MethodChannel get methodChannel {
    return _methodChannel;
  }

  EventChannel get eventChannel {
    return _eventChannel;
  }

  Future<bool> reactToNativeModule(FCPChannelTypes type, dynamic data) async {
    final value = await _methodChannel.invokeMethod(
        CPEnumUtils.stringFromEnum(type.toString()), data);
    return value;
  }

  static void updateCPListItem(CPListItem updatedListItem) {
    _methodChannel.invokeMethod('updateListItem',
        <String, dynamic>{...updatedListItem.toJson()}).then((value) {
      if (value) {
        l1:
        for (var h in templateHistory) {
          switch (h.runtimeType) {
            case CPTabBarTemplate:
              for (var t in (h as CPTabBarTemplate).templates) {
                for (var s in t.sections) {
                  for (var i in s.items) {
                    if (i.uniqueId == updatedListItem.uniqueId) {
                      currentRootTemplate!
                          .templates[currentRootTemplate!.templates.indexOf(t)]
                          .sections[t.sections.indexOf(s)]
                          .items[s.items.indexOf(i)] = updatedListItem;
                      break l1;
                    }
                  }
                }
              }
              break;
            case CPListTemplate:
              for (var s in (h as CPListTemplate).sections) {
                for (var i in s.items) {
                  if (i.uniqueId == updatedListItem.uniqueId) {
                    currentRootTemplate!
                        .sections[currentRootTemplate!.sections.indexOf(s)]
                        .items[s.items.indexOf(i)] = updatedListItem;
                    break l1;
                  }
                }
              }
              break;
            default:
          }
        }
      }
    });
  }

  static void updateMapTemplate(CPMapTemplate updatedMapTemplate) {
    _methodChannel.invokeMethod('updateMapTemplate',
        <String, dynamic>{...updatedMapTemplate.toJson()}).then((value) {
      if (value) {
        for (var h in templateHistory) {
          switch (h.runtimeType) {
            case CPTabBarTemplate:
              for (var t in (h as CPTabBarTemplate).templates) {
                if (t.uniqueId == updatedMapTemplate.uniqueId) {
                  currentRootTemplate = updatedMapTemplate;
                  break;
                }
              }
              break;
            case CPMapTemplate:
              if (h.uniqueId == updatedMapTemplate.uniqueId) {
                currentRootTemplate = updatedMapTemplate;
                break;
              }
              break;
            default:
          }
        }
      }
    });
  }

  static void showTripPreviews(
    String elementId,
    List<CPTrip> tripPreviews,
    CPTrip? selectedTrip,
    CPTripPreviewTextConfiguration? textConfiguration,
  ) {
    _methodChannel.invokeMethod(
        CPEnumUtils.stringFromEnum(FCPChannelTypes.showTripPreviews.toString()),
        {
          '_elementId': elementId,
          'tripPreviews': tripPreviews.map((e) => e.toJson()).toList(),
          'selectedTrip': selectedTrip?.toJson(),
          'textConfiguration': textConfiguration?.toJson(),
        });
  }

  static void hideTripPreviews(String elementId) {
    _methodChannel.invokeMethod(
        CPEnumUtils.stringFromEnum(FCPChannelTypes.hideTripPreviews.toString()),
        {
          '_elementId': elementId,
        });
  }

  static void showPanningInterface(String elementId, bool animated) {
    _methodChannel.invokeMethod(
        CPEnumUtils.stringFromEnum(
            FCPChannelTypes.showPanningInterface.toString()),
        {
          '_elementId': elementId,
          'animated': animated,
        });
  }

  static void dismissPanningInterface(String elementId, bool animated) {
    _methodChannel.invokeMethod(
        CPEnumUtils.stringFromEnum(
            FCPChannelTypes.dismissPanningInterface.toString()),
        {
          '_elementId': elementId,
          'animated': animated,
        });
  }

  static void zoomInMapView(String elementId, bool animated) {
    _methodChannel.invokeMethod(
        CPEnumUtils.stringFromEnum(FCPChannelTypes.zoomInMapView.toString()), {
      '_elementId': elementId,
      'animated': animated,
    });
  }

  static void zoomOutMapView(String elementId, bool animated) {
    _methodChannel.invokeMethod(
        CPEnumUtils.stringFromEnum(FCPChannelTypes.zoomOutMapView.toString()), {
      '_elementId': elementId,
      'animated': animated,
    });
  }

  static void moveToCurrentLocation(String elementId, bool animated) {
    _methodChannel.invokeMethod(
        CPEnumUtils.stringFromEnum(
            FCPChannelTypes.moveToCurrentLocation.toString()),
        {
          '_elementId': elementId,
          'animated': animated,
        });
  }

  void addTemplateToHistory(dynamic template) {
    if (template.runtimeType == CPTabBarTemplate ||
        template.runtimeType == CPGridTemplate ||
        template.runtimeType == CPInformationTemplate ||
        template.runtimeType == CPPointOfInterestTemplate ||
        template.runtimeType == CPListTemplate ||
        template.runtimeType == CPMapTemplate) {
      templateHistory.add(template);
    } else {
      throw TypeError();
    }
  }

  void processFCPListItemSelectedChannel(String elementId) {
    CPListItem? listItem = _carplayHelper.findCPListItem(
      templates: templateHistory,
      elementId: elementId,
    );
    if (listItem != null) {
      listItem.onPress!(
        () => reactToNativeModule(
          FCPChannelTypes.onFCPListItemSelectedComplete,
          listItem.uniqueId,
        ),
        listItem,
      );
    }
  }

  void processFCPAlertActionPressed(String elementId) {
    CPAlertAction selectedAlertAction = currentPresentTemplate!.actions
        .firstWhere((e) => e.uniqueId == elementId);
    selectedAlertAction.onPress();
  }

  void processFCPAlertTemplateCompleted(bool completed) {
    if (currentPresentTemplate?.onPresent != null) {
      currentPresentTemplate!.onPresent!(completed);
    }
  }

  void processFCPGridButtonPressed(String elementId) {
    CPGridButton? gridButton;
    l1:
    for (var t in templateHistory) {
      if (t.runtimeType.toString() == "CPGridTemplate") {
        for (var b in t.buttons) {
          if (b.uniqueId == elementId) {
            gridButton = b;
            break l1;
          }
        }
      }
    }
    if (gridButton != null) gridButton.onPress();
  }

  void processFCPBarButtonPressed(String elementId) {
    CPBarButton? barButton;
    l1:
    for (var t in templateHistory) {
      if (t.runtimeType.toString() == "CPListTemplate") {
        barButton = t.backButton;
        break l1;
      } else if (t.runtimeType.toString() == "CPMapTemplate") {
        final barButtons =
            t.leadingNavigationBarButtons + t.trailingNavigationBarButtons;

        if (t.backButton != null) {
          barButtons.add(t.backButton);
        }
        for (CPBarButton b in barButtons) {
          if (b.uniqueId == elementId) {
            barButton = b;
            break l1;
          }
        }
      }
    }
    if (barButton != null) barButton.onPress();
  }

  void processFCPTextButtonPressed(String elementId) {
    l1:
    for (var t in templateHistory) {
      if (t.runtimeType.toString() == "CPPointOfInterestTemplate") {
        for (CPPointOfInterest p in t.poi) {
          if (p.primaryButton != null &&
              p.primaryButton!.uniqueId == elementId) {
            p.primaryButton!.onPress();
            break l1;
          }
          if (p.secondaryButton != null &&
              p.secondaryButton!.uniqueId == elementId) {
            p.secondaryButton!.onPress();
            break l1;
          }
        }
      } else {
        if (t.runtimeType.toString() == "CPInformationTemplate") {
          l2:
          for (CPTextButton b in t.actions) {
            if (b.uniqueId == elementId) {
              b.onPress();
              break l2;
            }
          }
        }
      }
    }
  }

  void processFCPMapButtonPressed(String elementId) {
    l1:
    for (var t in templateHistory) {
      if (t.runtimeType.toString() == "CPMapTemplate") {
        for (CPMapButton b in t.mapButtons) {
          if (b.uniqueId == elementId) {
            b.onPress();
            break l1;
          }
        }
      }
    }
  }
}
