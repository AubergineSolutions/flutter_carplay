import 'package:uuid/uuid.dart';

class CPTripPreviewTextConfiguration {
  /// Unique id of the object.
  final String _elementId = const Uuid().v4();

  /// Start button title
  final String? startButtonTitle;

  /// Additional routes button title
  final String? additionalRoutesButtonTitle;

  /// Overview button title
  final String? overviewButtonTitle;

  /// Creates a new [CPTripPreviewTextConfiguration] object.
  CPTripPreviewTextConfiguration(
      {this.startButtonTitle,
      this.additionalRoutesButtonTitle,
      this.overviewButtonTitle});

  /// Converts the CPTripPreviewTextConfiguration object to a JSON object.
  Map<String, dynamic> toJson() => {
        "_elementId": _elementId,
        "startButtonTitle": startButtonTitle,
        "additionalRoutesButtonTitle": additionalRoutesButtonTitle,
        "overviewButtonTitle": overviewButtonTitle
      };

  /// Returns the unique id of the object.
  String get uniqueId => _elementId;
}
