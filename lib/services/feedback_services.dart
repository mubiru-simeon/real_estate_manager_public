import 'package:dorx/models/models.dart';
import 'package:flutter/material.dart';
import '../widgets/feedback_options_bottom_sheet.dart';
import 'services.dart';

class FeedbackServices {
  startFeedingBackward(
    BuildContext context,
    String mode,
  ) {
    if (mode == ThingType.PROPERTYMANAGER) {
      UIServices().showDatSheet(
        FeedbackOptionsBottomSheet(
          additionalInfo: null,
        ),
        true,
        context,
      );
    } else {
      UIServices().showDatSheet(
        OnlyTextBottomSheet(
          category: UserFeedback.FEATURE,
        ),
        true,
        context,
      );
    }
  }
}
