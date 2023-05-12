import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  static const DIRECTORY = "users";
  static const CUSTOMERCOUNT = "customerCount";

  static const USERSBYTYPE = "usersByType";

  static const ACCOUNTTYPES = "accountTypes";
  static const LASTLOGINTIME = "lastLogin";
  static const LASTLOGOUTTIME = "lastLogout";
  static const PERMISSIONUPDATES = "permissionUpdates";
  static const PASSWORD = "password";
  static const USERDATA = "userData";
  static const FCMTOKENS = "userFCMTokens";

  static const USERNAME = "userName";
  static const EMAIL = "email";
  static const PHONENUMBER = "phoneNumber";
  static const PROFILEPIC = "profilePic";
  static const IMAGES = "images";
  static const WHATSAPPNUMBER = "whatsappNumber";
  static const GENDER = "gender";
  static const ADDRESS = "address";

  static const REGISTERER = "registerer";
  static const TIMEOFJOINING = "time";
  static const TYPE = "type";
  static const ADDING = "adding";
  static const AFFILIATION = "affiliation";
  static const SETTINGSMAP = "settingsMap";
  static const REMOVING = "removing";
  static const REFEREES = "referees";
  static const MODE = "mode";

  String _id;
  String _email;
  List _referees;
  Map _userData;
  String _userName;
  String _profilePic;
  String _phoneNumber;
  EntityUserData _entityUserData;
  Map _permissionUpdate;
  String _adder;
  dynamic _settingsMap;
  int _date;
  List _images;
  String _type;
  String _address;
  List _affiliations;
  String _whatsappNumber;
  String _gender;

  EntityUserData get entityUserData => _entityUserData;
  String get gender => _gender;
  Map get permissionUpdates => _permissionUpdate;
  String get adder => _adder;
  int get date => _date;
  String get address => _address;
  Map get userData => _userData;
  List get affiliations => _affiliations;
  List get referees => _referees;
  String get whatsappNumber => _whatsappNumber;
  String get email => _email;
  String get id => _id;
  dynamic get settingsMAp => _settingsMap;
  String get userName => _userName;
  String get type => _type;
  String get profilePic => _profilePic;
  List get images => _images;
  String get phoneNumber => _phoneNumber;

  UserModel.fromSnapshot(
    DocumentSnapshot snapshot,
    String entityID,
  ) {
    Map pp = (snapshot.data() as Map) ?? {};

    _phoneNumber = pp[PHONENUMBER] ?? "";
    _userName = pp[USERNAME] ?? "User_$_id";
    _profilePic = pp[PROFILEPIC];
    _permissionUpdate = pp[PERMISSIONUPDATES] ?? {};
    _referees = pp[REFEREES] ?? [];
    _email = pp[EMAIL];
    _images = pp[IMAGES];
    _whatsappNumber = pp[WHATSAPPNUMBER];
    _adder = pp[REGISTERER];
    _date = pp[TIMEOFJOINING];
    _affiliations = pp[AFFILIATION] ?? [];
    _address = pp[ADDRESS] ?? "Kampala";
    _userData = pp[USERDATA] ?? {};
    _settingsMap = pp[SETTINGSMAP] ?? {};
    _images = pp[IMAGES] ?? [];
    _gender = pp[GENDER] ?? "male";
    _id = snapshot.id;

    if (pp[USERDATA] == null ||
        _userData[entityID] == null ||
        _userData[entityID].isEmpty) {
      Map pp = {};
      _userData.forEach((key, value) {
        pp.addAll({
          key: value,
        });
      });

      pp.addAll({
        entityID: {
          UserModel.USERNAME: _userName,
          UserModel.PROFILEPIC: _profilePic,
          UserModel.EMAIL: _email,
          UserModel.GENDER: _gender,
          UserModel.ADDRESS: _address,
          UserModel.PHONENUMBER: _phoneNumber,
          UserModel.WHATSAPPNUMBER: _whatsappNumber,
        }
      });

      FirebaseFirestore.instance
          .collection(UserModel.DIRECTORY)
          .doc(_id)
          .update({
        UserModel.USERDATA: pp,
      });

      _userData = pp;
    } else {
      _entityUserData = EntityUserData.fromData(pp[USERDATA][entityID]);

      _userName = entityUserData.userName;
      _email = entityUserData.email;
      _gender = entityUserData.gender;
      _referees = entityUserData.referees;
      _phoneNumber = entityUserData.phoneNumber;
      _profilePic = entityUserData.profilePic;
      _whatsappNumber = entityUserData.whatsappNumber;
      _address = entityUserData.address;
      _images = entityUserData.images;
    }
  }

  UserModel.fromData({
    @required String phoneNumber,
    @required String username,
    @required String profilePic,
    @required String type,
    @required String email,
    @required String address,
    @required String whatsappNumber,
    @required String gender,
    @required String registerer,
    @required List images,
    @required List referees,
  }) {
    _phoneNumber = phoneNumber;
    _userName = username;
    _address = address;
    _type = type;
    _whatsappNumber = whatsappNumber;
    _gender = gender;
    _adder = registerer;
    _referees = referees;
    _profilePic = profilePic;
    _email = email;
    _images = images;
  }
}

class EntityUserData {
  String _email;
  List _referees;
  String _userName;
  String _profilePic;
  String _phoneNumber;
  List _images;
  String _address;
  String _whatsappNumber;
  String _gender;

  String get gender => _gender;
  String get address => _address;
  List get referees => _referees;
  String get whatsappNumber => _whatsappNumber;
  String get email => _email;
  String get userName => _userName;
  String get profilePic => _profilePic;
  List get images => _images;
  String get phoneNumber => _phoneNumber;

  EntityUserData.fromData(
    Map pp,
  ) {
    _email = pp[UserModel.EMAIL];
    _phoneNumber = pp[UserModel.PHONENUMBER];
    _userName = pp[UserModel.USERNAME];
    _profilePic = pp[UserModel.PROFILEPIC];
    _referees = pp[UserModel.REFEREES] ?? [];
    _images = pp[UserModel.IMAGES];
    _whatsappNumber = pp[UserModel.WHATSAPPNUMBER];
    _address = pp[UserModel.ADDRESS] ?? "Kampala";
    _images = pp[UserModel.IMAGES] ?? [];
    _gender = pp[UserModel.GENDER] ?? "male";
  }
}

class UsualCustomer {
  static const DIRECTORY = "usualCustomers";
  static const TRANSACTIONCOUNT = "transactionCount";
}
