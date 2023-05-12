import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserFeedback {
  static const DIRECTORY = "feedback";

  static const SENDER = "sender";
  static const CATEGORY = "category";
  static const ENTITY = "entity";
  static const INTERNAL = "internal";
  static const APPVERSION = "appVersion";
  static const TEXT = "text";
  static const ATTACHEDDATA = "attachedData";
  static const DATE = "date";
  static const ADDITIONALINFO = "additionalInfo";
  static const PENDING = "pending";
  static const IMAGES = "images";

  static const REPORT = "report";
  static const CONTACTUSVIEW = "contactUsView";
  static const BUG = "bug";
  static const FEATURE = "feature";
  static const LIKES = "likes";
  static const DISLIKES = "dislikes";

  String _id;
  String _category;
  int _date;
  String _sender;
  bool _internal;
  int _appVersion;
  String _text;
  bool _pending;

  String get id => _id;
  String get category => _category;
  bool get internal => _internal;
  int get appVersion => _appVersion;
  int get date => _date;
  String get text => _text;
  bool get pending => _pending;
  String get sender => _sender;

  UserFeedback.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _id = snapshot.id;
    _category = pp[CATEGORY] ?? UserFeedback.FEATURE;
    _appVersion = pp[APPVERSION];
    _internal = pp[INTERNAL] ?? false;
    _date = pp[DATE];
    _pending = pp[PENDING] ?? false;
    _text = pp[TEXT];
  }
}

class TempFeedback {
  /// Creates an [TempFeedback].
  /// Typically never used by a user of this library.
  TempFeedback({
    @required this.text,
    @required this.screenshot,
    this.extra,
  });

  /// The user's written feedback
  final String text;

  /// A raw png encoded screenshot of the app. Probably annotated with helpful
  /// drawings by the user.
  final Uint8List screenshot;

  /// This can contain additional information. By default this is always empty.
  /// When using a custom [BetterFeedback.feedbackBuilder] this can be used
  /// to supply additional information.
  final Map<String, dynamic> extra;
}
