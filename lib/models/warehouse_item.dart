import 'package:cloud_firestore/cloud_firestore.dart';

class StorageItemTransaction {
  static const DIRECTORY = "storeItemsTransactions";
  static const ITEM = "item";

  dynamic _amount;
  int _date;

  dynamic get amount => _amount;
  int get date => _date;

  StorageItemTransaction.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _amount = pp[StorageItem.AMOUNT];
    _date = pp[StorageItem.DATE];
  }
}

class StorageItem {
  static const DIRECTORY = "storageItems";
  static const ENTITY = "entity";
  static const DATE = "date";
  static const ENTITYTYPE = "entityType";
  static const ENTITYAPPLINK = "entityAppLink";
  static const NAME = "name";
  static const PRICE = "price";
  static const UNITS = "units";
  static const ADDER = "adder";
  static const AMOUNT = "amount";

  String _id;
  String _name;
  String _entity;
  int _date;
  dynamic _price;
  String _unit;
  dynamic _amount;

  String get id => _id;
  String get name => _name;
  String get entity => _entity;
  int get date => _date;
  dynamic get price => _price;
  String get unit => _unit;
  dynamic get amount => _amount;

  StorageItem.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _name = pp[NAME];
    _amount = pp[AMOUNT] ?? 0;
    _id = snapshot.id;
    _date = pp[DATE];
    _entity = pp[ENTITY];
    _price = pp[PRICE];
    _unit = pp[UNITS];
  }
}
