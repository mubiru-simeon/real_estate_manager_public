import 'package:flutter/cupertino.dart';
import 'package:dorx/models/delivery_location.dart';

class UsableConstants with ChangeNotifier {
  static const DELIVERYLOCATION = "deliveryLocation";
  static const USERLOCATION = "userLocation";
  static const DELIVERYFEE = "deliveryFee";
  static const DELIVERYNAME = "deliveryName";

  Map<String, dynamic> usableConstants = {};

  Map get deliveryFeesMap {
    return usableConstants[DELIVERYFEE];
  }

  hasDeliveryPrice(String mode) {
    return usableConstants.isNotEmpty &&
        usableConstants[DELIVERYFEE] != null &&
        usableConstants[DELIVERYFEE].isNotEmpty;
  }

  DeliveryLocation get currentDeliveryLocation {
    return usableConstants[DELIVERYLOCATION];
  }

  DeliveryLocation get currentUserLocation {
    return usableConstants[USERLOCATION];
  }

  addDeliveryLocation(
    DeliveryLocation deliveryLocation,
    String deliveryName,
  ) {
    usableConstants.addAll({
      DELIVERYLOCATION: deliveryLocation,
      DELIVERYNAME: deliveryName,
    });

    notifyListeners();
  }

  addUserLocation(
    DeliveryLocation deliveryLocation,
    String deliveryName,
  ) {
    usableConstants.addAll({
      USERLOCATION: deliveryLocation,
      DELIVERYNAME: deliveryName,
    });

    notifyListeners();
  }

  removeDeliveryLocation(BuildContext context) {
    usableConstants.remove(DELIVERYLOCATION);
    usableConstants.remove(DELIVERYNAME);

    removeAllDeliveryFees();
    notifyListeners();
  }

  updateDeliveryFeeForStore(
    int fee,
    String serviceProvider,
  ) {
    if (usableConstants[DELIVERYFEE] != null) {
      usableConstants[DELIVERYFEE].addAll({
        serviceProvider: fee,
      });
    } else {
      usableConstants.addAll({
        DELIVERYFEE: {
          serviceProvider: fee,
        }
      });
    }
    //notifyListeners();
  }

  int deliveryFee(String mode) {
    int totalFee = 0;
    if (usableConstants[DELIVERYFEE] != null) {
      usableConstants[DELIVERYFEE].forEach((key, value) {
        totalFee = totalFee + value;
      });
    }

    return totalFee;
  }

  removeAllDeliveryFees() {
    usableConstants.remove(DELIVERYFEE);

    notifyListeners();
  }
}
