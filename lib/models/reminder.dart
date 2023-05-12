import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  static const DIRECTORY = "reminders";

  static const THINGTYPE = "thingType";
  static const REMINDERTYPE = "reminderType";
  static const THINGID = "thingID";
  static const DAY = "day";
  static const HOUR = "hour";
  static const MINUTE = "minute";
  static const CANCELLED = "cancelled";
  static const DATE = "date";
  static const ENTITYAPPLINK = "entityAppLink";
  static const PARTNERAPPLINK = "partnerAppLink";
  static const ENTITYMESSAGE = "entityMessage";
  static const PARTNERMESSAGE = "partnerMessage";
  static const ENTITY = "entity";
  static const ENTITYTYPE = "entityType";
  static const PARTNERTYPE = "partnerType";
  static const PARTNER = "partner";
  static const MONTH = "month";
  static const YEAR = "year";
  static const CALLOFFID = "callOffID";
  static const CRONJOBID = "cronID";

  static const RENTISDUE = "rent is due";
  static const RENTISALMOSTDUE = "rent is almost due";
  static const CUSTOM = "custom";

  dynamic _cronJobID;
  String _entityMessage;
  String _partnerMessage;
  String _thingType;
  String _reminderType;
  dynamic _day;
  dynamic _month;
  dynamic _hour;
  String _partner;
  String _partnerType;
  dynamic _minute;
  bool _cancelled;
  String _thingID;
  String _id;

  dynamic get cronJobID => _cronJobID;
  String get entityMessage => _entityMessage;
  String get partnerMessage => _partnerMessage;
  dynamic get day => _day;
  dynamic get month => _month;
  dynamic get hour => _hour;
  dynamic get minute => _minute;
  String get thingID => _thingID;
  bool get cancelled => _cancelled;
  String get partner => _partner;
  String get partnerType => _partnerType;
  String get id => _id;
  String get thingType => _thingType;
  String get reminderType => _reminderType;

  Reminder.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _thingType = pp[THINGTYPE] ?? RENTISDUE;
    _reminderType = pp[REMINDERTYPE] ?? RENTISDUE;
    _id = snapshot.id;
    _day = pp[DAY];
    _entityMessage = pp[ENTITYMESSAGE];
    _partnerMessage = pp[PARTNERMESSAGE];
    _month = pp[MONTH];
    _hour = pp[HOUR] ?? 9;
    _minute = pp[MINUTE] ?? 30;
    _cancelled = pp[CANCELLED] ?? false;
    _partner = pp[PARTNER];
    _partnerType = pp[PARTNERTYPE];
    _thingID = pp[THINGID];
    _cronJobID = pp[CRONJOBID];
  }
}
