
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';

class UsualRecepients {
  String _id;
  int _date;
  String _type;

  String get id => _id;
  int get date => _date;
  String get type => _type;

  UsualRecepients.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _id = pp[Payment.THINGID];
    _type = pp[Payment.THINGTYPE] ?? ThingType.USER;
  }
}