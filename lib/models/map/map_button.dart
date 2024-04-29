import 'package:uuid/uuid.dart';

/// A button object for placement in a map template.
class CPMapButton {
  /// Unique id of the object.
  final String _elementId = const Uuid().v4();

  /// Whether the button is enabled.
  final bool isEnabled;

  /// Whether the button is hidden.
  final bool isHidden;

  /// The button's image.
  final String? image;

  /// The button's focused image.
  final String? focusedImage;

  /// The button's callback.
  final Function() onPress;

  /// Creates a button object for placement in a map template.
  CPMapButton({
    this.isEnabled = true,
    this.isHidden = false,
    required this.onPress,
    this.image,
    this.focusedImage,
  });

  Map<String, dynamic> toJson() => {
        "_elementId": _elementId,
        "isEnabled": isEnabled,
        "isHidden": isHidden,
        "image": image,
        "focusedImage": focusedImage,
      };

  /// Returns the unique id of the object.
  String get uniqueId => _elementId;
}
