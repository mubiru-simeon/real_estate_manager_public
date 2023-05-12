import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolModel {
  static const DIRECTORY = "schools";

  static const NAME = "name";
  static const MOTTO = "motto";
  static const BADGE = "badge";
  static const ADDRESS = "address";
  static const TIMEADDED = "timeAdded";
  static const LAT = "lat";
  static const LONG = "long";

  String _name;
  String _motto;
  String _id;
  String _image;
  String _address;
  double _lat;
  double _long;

  String get name => _name;
  String get motto => _motto;
  String get id => _id;
  String get image => _image;
  double get lat => _lat;
  double get long => _long;
  String get address => _address;

  SchoolModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _address = pp[ADDRESS];
    _id = snapshot.id;
    _image = pp[BADGE];
    _motto = pp[MOTTO];
    _name = pp[NAME];
    _lat = pp[LAT];
    _long = pp[LONG];
  }
}
