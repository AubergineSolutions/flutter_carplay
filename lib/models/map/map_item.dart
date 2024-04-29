import 'package:uuid/uuid.dart';

/// A map item object displayed on a map template.
class MKMapItem {
  /// Unique id of the object.
  final String _elementId = const Uuid().v4();

  /// Latitude of the map item.
  final double latitude;

  /// Longitude of the map item.
  final double longitude;

  /// Name of the map item
  final String? name;

  /// Constructor for [MKMapItem]
  MKMapItem({required this.latitude, required this.longitude, this.name});

  Map<String, dynamic> toJson() => {
        "_elementId": _elementId,
        "latitude": latitude,
        "longitude": longitude,
        "name": name
      };

  String get uniqueId => _elementId;
}
