import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  static const DIRECTORY = "expenses";

  static const ENTITY = "entity";
  static const ENTITYTYPE = "entityType";
  static const DATE = "date";
  static const AMOUNT = "amount";
  static const CATEGORY = "category";
  static const CATEGORYID = "categoryID";
  static const ADDER = "adder";
  static const DETAILS = "details";

  String _id;
  String _additionalInfo;
  String _details;
  String _categoryName;
  String _entity;
  String _entityType;
  dynamic _amount;
  int _date;

  String get id => _id;
  String get additionalInfo => _additionalInfo;
  String get details => _details;
  dynamic get amount => _amount;
  String get entityType => _entityType;
  String get entity => _entity;
  String get categoryName => _categoryName;
  int get date => _date;

  Expense.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _id = snapshot.id;
    _amount = pp[AMOUNT] ?? 0;
    _date = pp[DATE];
    _categoryName = pp[CATEGORY];
    _entity = pp[ENTITY];
    _details = pp[DETAILS];
    _entityType = pp[ENTITYTYPE];
  }
}

class ExpenseCategory {
  static const DIRECTORY = "expenseCategories";

  static const ENTITY = "entity";
  static const NAME = "name";
  static const DATE = "date";
  static const ADDER = "adder";

  String _name;
  String _id;
  dynamic _amount;

  String get name => _name;
  dynamic get amount => _amount;
  String get id => _id;

  ExpenseCategory.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _name = pp[NAME];
    _amount = pp[Expense.AMOUNT] ?? 0;
    _id = snapshot.id;
  }
}
