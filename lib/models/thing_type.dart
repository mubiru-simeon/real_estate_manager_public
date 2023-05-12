import 'package:dorx/services/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ThingType {
  static const PROPERTY = "property";
  static const USER = "user";

  static const PROPERTYMANAGER = "property manager";
  static const RECEPTIONIST = "receptionist";
  static const ADMIN = "admin";
  static const CUSTOMER = "customer";
}

Map categoryModes = {
  ThingType.PROPERTY.capitalizeFirstOfEach: FontAwesomeIcons.house,
  ThingType.USER.capitalizeFirstOfEach: FontAwesomeIcons.user,
};
