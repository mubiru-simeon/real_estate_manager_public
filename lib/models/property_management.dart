import 'package:flutter/material.dart';

import 'models.dart';

class PropertyManagement extends ChangeNotifier {
  static const PROPERTYID = "propertyID";
  static const PROPERTYMODEL = "propertyModel";

  Map<String, dynamic> data = {};

  editPropertyID(
    String id,
    bool notify,
  ) {
    if (id != null) {
      data.addAll({
        PROPERTYID: id,
      });
    } else {
      data.remove(
        PROPERTYID,
      );
    }

    if (notify) {
      notifyListeners();
    }
  }

  editPropertyModel(
    Property property,
    bool notify,
  ) {
    if (property != null) {
      data.addAll({
        PROPERTYMODEL: property,
      });
    } else {
      data.remove(
        PROPERTYMODEL,
      );
    }

    if (notify) {
      notifyListeners();
    }
  }

  clear() {
    data.clear();

    notifyListeners();
  }

  String getCurrentPropertyID() {
    return data[PROPERTYID];
  }

  Property getCurrentPropertyModel() {
    return data[PROPERTYMODEL];
  }
}
