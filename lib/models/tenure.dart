import 'package:cloud_firestore/cloud_firestore.dart';

class Tenure {
  static const NAME = "name";
  static const DIRECTORY = "tenures";
  static const DATE = "date";

  String _name = "name";

  String get name => _name;

  Tenure.fromSnapshot(DocumentSnapshot snapshot) {
    // Map pp = snapshot.data() as Map;

    _name = snapshot.id;
  }
}
