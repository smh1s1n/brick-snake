import 'package:flutter/services.dart';

class HapticUtil {
  static void lightClick() {
    HapticFeedback.lightImpact();
  }

  static void mediumClick() {
    HapticFeedback.mediumImpact();
  }

  static void crashVibrate() {
    HapticFeedback.heavyImpact();
  }
}
