import 'package:flutter_carplay/helpers/enum_utils.dart';
import 'package:flutter_carplay/models/button/alert_constants.dart';
import 'package:uuid/uuid.dart';

/// A button object for placement in a navigation bar.
class CPBarButton {
  /// Unique id of the object.
  final String _elementId = const Uuid().v4();

  /// The title displayed on the bar button.
  final String? title;

  /// The image displayed on the bar button.
  final String? image;

  /// The style to use when displaying the button.
  /// Default is [CPBarButtonStyles.rounded]
  final CPBarButtonStyles style;

  /// Fired when the user taps a bar button.
  final Function() onPress;

  /// Creates [CPBarButton] with a title, style and handler.
  CPBarButton({
    this.title,
    this.image,
    this.style = CPBarButtonStyles.rounded,
    required this.onPress,
  })  : assert(
          image != null || title != null,
          "Properties [image] and [title] both can't be null at the same time.",
        ),
        assert(
          image == null || title == null,
          "Properties [image] and [title] both can't be set at the same time.",
        );

  Map<String, dynamic> toJson() => {
        "_elementId": _elementId,
        "title": title,
        "image": image,
        "style": CPEnumUtils.stringFromEnum(style.toString()),
      };

  String get uniqueId {
    return _elementId;
  }
}
