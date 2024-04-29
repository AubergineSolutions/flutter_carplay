import 'package:uuid/uuid.dart';

/// A route choice object.
class CPRouteChoice {
  /// Unique id of the object.
  final String _elementId = const Uuid().v4();

  /// Summary of the route choice.
  final List<String>? summaryVariants;

  /// Summary of the route choice when the user selects it.
  final List<String>? selectionSummaryVariants;

  /// Additional information about the route choice.
  final List<String>? additionalInformationVariants;

  /// Creates a new [CPRouteChoice] object.
  CPRouteChoice({
    this.summaryVariants,
    this.selectionSummaryVariants,
    this.additionalInformationVariants,
  });

  /// Converts the CPRouteChoice object to a JSON object.
  Map<String, dynamic> toJson() => {
        "_elementId": _elementId,
        "summaryVariants": summaryVariants,
        "selectionSummaryVariants": selectionSummaryVariants,
        "additionalInformationVariants": additionalInformationVariants
      };

  /// Returns the unique id of the object.
  String get uniqueId => _elementId;
}
