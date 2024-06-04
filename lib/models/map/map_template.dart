import 'package:flutter_carplay/constants/constants.dart';
import 'package:flutter_carplay/controllers/carplay_controller.dart';
import 'package:flutter_carplay/helpers/enum_utils.dart';
import 'package:flutter_carplay/models/button/bar_button.dart';
import 'package:flutter_carplay/models/map/map_button.dart';
import 'package:flutter_carplay/models/map/trip.dart';
import 'package:flutter_carplay/models/map/trip_preview_text_configuration.dart';
import 'package:uuid/uuid.dart';

/// A template object that displays map.
class CPMapTemplate {
  /// Unique id of the object.
  final String _elementId = const Uuid().v4();

  /// The background color of the guidance.
  int guidanceBackgroundColor;

  CPTripEstimateStyle tripEstimateStyle;

  /// A list of map buttons.
  final List<CPMapButton> mapButtons;

  /// A list of leading navigation bar buttons.
  final List<CPBarButton> leadingNavigationBarButtons;

  /// A list of trailing navigation bar buttons.
  final List<CPBarButton> trailingNavigationBarButtons;

  /// Automatically hides the navigation bar.
  final bool automaticallyHidesNavigationBar;

  /// Hides the buttons with navigation bar.
  final bool hidesButtonsWithNavigationBar;

  /// Back button object
  final CPBarButton? backButton;

  /// Creates a new [CPMapTemplate] object.
  CPMapTemplate({
    this.guidanceBackgroundColor = 0,
    this.tripEstimateStyle = CPTripEstimateStyle.light,
    this.mapButtons = const [],
    this.leadingNavigationBarButtons = const [],
    this.trailingNavigationBarButtons = const [],
    this.automaticallyHidesNavigationBar = true,
    this.hidesButtonsWithNavigationBar = true,
    this.backButton,
  });

  /// Converts the CPMapTemplate object to a JSON object.
  Map<String, dynamic> toJson() => {
        "_elementId": _elementId,
        "guidanceBackgroundColor": guidanceBackgroundColor,
        "tripEstimateStyle":
            CPEnumUtils.stringFromEnum(tripEstimateStyle.toString()),
        "mapButtons": mapButtons.map((e) => e.toJson()).toList(),
        "leadingNavigationBarButtons":
            leadingNavigationBarButtons.map((e) => e.toJson()).toList(),
        "trailingNavigationBarButtons":
            trailingNavigationBarButtons.map((e) => e.toJson()).toList(),
        "automaticallyHidesNavigationBar": automaticallyHidesNavigationBar,
        "hidesButtonsWithNavigationBar": hidesButtonsWithNavigationBar,
        "backButton": backButton?.toJson(),
      };

  void setMapButtons(List<CPMapButton> mapButtons) {
    this.mapButtons.clear();
    this.mapButtons.addAll(mapButtons);
    FlutterCarPlayController.updateMapTemplate(this);
  }

  void setLeadingNavigationBarButtons(
      List<CPBarButton> leadingNavigationBarButtons) {
    this.leadingNavigationBarButtons.clear();
    this.leadingNavigationBarButtons.addAll(leadingNavigationBarButtons);
    FlutterCarPlayController.updateMapTemplate(this);
  }

  void setTrailingNavigationBarButtons(
      List<CPBarButton> trailingNavigationBarButtons) {
    this.trailingNavigationBarButtons.clear();
    this.trailingNavigationBarButtons.addAll(trailingNavigationBarButtons);
    FlutterCarPlayController.updateMapTemplate(this);
  }

  /// Show trip previews.
  void showTripPreviews(
    List<CPTrip> tripPreviews,
    CPTrip? selectedTrip,
    CPTripPreviewTextConfiguration? textConfiguration,
  ) {
    FlutterCarPlayController.showTripPreviews(
      _elementId,
      tripPreviews,
      selectedTrip,
      textConfiguration,
    );
  }

  /// Hide trip previews.
  void hideTripPreviews() {
    FlutterCarPlayController.hideTripPreviews(_elementId);
  }

  /// Start navigation.
  void startNavigation() {}

  /// Stop navigation.
  void stopNavigation() {}

  /// Show panning interface.
  void showPanningInterface(bool animated) {
    FlutterCarPlayController.showPanningInterface(_elementId, animated);
  }

  /// Dismiss panning interface.
  void dismissPanningInterface(bool animated) {
    FlutterCarPlayController.dismissPanningInterface(_elementId, animated);
  }

  void setGuidanceBackgroundColor(int guidanceBackgroundColor) {
    this.guidanceBackgroundColor = guidanceBackgroundColor;
  }

  void setTripEstimateStyle(CPTripEstimateStyle tripEstimateStyle) {
    this.tripEstimateStyle = tripEstimateStyle;
  }

  void zoomIn(bool animated) {
    FlutterCarPlayController.zoomInMapView(_elementId, animated);
  }

  void zoomOut(bool animated) {
    FlutterCarPlayController.zoomOutMapView(_elementId, animated);
  }

  void moveToCurrentLocation(bool animated) {
    FlutterCarPlayController.moveToCurrentLocation(_elementId, animated);
  }

  /// Returns the unique id of the object.
  String get uniqueId => _elementId;
}
