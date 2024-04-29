import 'package:flutter_carplay/models/map/map_item.dart';
import 'package:flutter_carplay/models/map/route_choice.dart';
import 'package:uuid/uuid.dart';

class CPTrip {
  /// Unique id of the object.
  final String _elementId = const Uuid().v4();

  /// Origin of the trip.
  final MKMapItem origin;

  /// Destination of the trip.
  final MKMapItem destination;

  /// Route choices of the trip.
  final List<CPRouteChoice> routeChoices;

  /// Creates a new [CPTrip] object.
  CPTrip(this.origin, this.destination, this.routeChoices);

  /// Converts the CPTrip object to a JSON object.
  Map<String, dynamic> toJson() => {
        "_elementId": _elementId,
        "origin": origin.toJson(),
        "destination": destination.toJson(),
        "routeChoices": routeChoices.map((e) => e.toJson()).toList(),
      };

  /// Returns the unique id of the object.
  String get uniqueId => _elementId;
}
