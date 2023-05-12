import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/models/models.dart';

class Booking {
  static const DIRECTORY = "bookings";

  static const START = "start";
  static const PROPERTY = "property";
  static const STOP = "stop";
  static const OWNER = "owner";
  static const ADULTCOUNT = "adultCount";
  static const CHILDCOUNT = "childCount";
  static const PETCOUNT = "petCount";
  static const CUSTOMERMAP = "customerMap";
  static const CUSTOMER = "customer";
  static const PROPERTYPRICE = "propertyPrice";
  static const CHECKERIN = "checkerIn";
  static const DATEOFCHECKINGIN = "dateOfCheckingIn";
  static const PAYMENTAMOUNT = "paymentAmount";
  static const DATE = "date";
  static const BUYER = "buyer";
  static const DATEOFPAYMENT = "dateOfPayment";
  static const OFFEREDROOMS = "offeredRooms";
  static const SELECTEDROOMS = "selectedRooms";
  static const LUGGAGE = "luggage";
  static const CHECKEDINGUESTS = "checkedInGuests";
  static const INEEDALIFT = "needALift";

  //booking states
  static const PENDING = "pending";
  static const COMPLETE = "complete";
  static const CANCELLED = "cancelled";
  static const APPROVED = "approved";
  static const REJECTED = "rejected";
  static const ONGOING = "ongoing";
  static const CHECKEDIN = "checkedIn";

  //state managers
  static const CANCELLER = "canceller";

  String _customer;
  bool _pending;
  List _roomsRequested;
  bool _cancelled;
  bool _rejected;
  int _date;
  String _id;
  bool _complete;
  bool _ongoing;
  bool _checkedIn;
  bool _approved;

  Map _offeredRooms;
  bool _luggage;
  int _start;
  bool _needALift;
  String _property;
  String _name;
  List _selectedRooms;
  String _phone;
  String _town;
  String _email;
  int _childrenCount;
  int _adultCount;
  int _petCount;
  int _stop;

  String get customer => _customer;
  bool get pending => _pending;
  bool get cancelled => _cancelled;
  bool get rejected => _rejected;
  bool get complete => _complete;
  String get id => _id;
  bool get needALift => _needALift;
  bool get ongoing => _ongoing;
  int get date => _date;
  List get roomsRequested => _roomsRequested;
  bool get checkedIn => _checkedIn;
  bool get approved => _approved;

  Map get offeredRooms => _offeredRooms;
  int get start => _start;
  int get stop => _stop;
  String get property => _property;
  String get phone => _phone;
  String get name => _name;
  String get town => _town;
  int get adultCount => _adultCount;
  int get petCount => _petCount;
  bool get luggage => _luggage;
  String get email => _email;
  List get selectedRooms => _selectedRooms;
  int get childCount => _childrenCount;

  Booking.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _id = snapshot.id;
    _customer = pp[CUSTOMER];
    _pending = pp[PENDING];
    _cancelled = pp[CANCELLED];
    _rejected = pp[REJECTED];
    _complete = pp[COMPLETE];
    _date = pp[DATE];
    _ongoing = pp[ONGOING];
    _checkedIn = pp[CHECKEDIN];
    _roomsRequested = pp[SELECTEDROOMS] ?? [];
    _approved = pp[APPROVED];

    _offeredRooms = pp[OFFEREDROOMS] ?? {};
    _start = pp[START] ?? DateTime.now().millisecondsSinceEpoch;
    _stop = pp[STOP] ?? _start;
    _adultCount = pp[ADULTCOUNT] ?? 0;
    _selectedRooms = pp[SELECTEDROOMS];
    _needALift = pp[INEEDALIFT] ?? false;
    _childrenCount = pp[CHILDCOUNT] ?? 0;
    _property = pp[PROPERTY];
    _luggage = pp[LUGGAGE] ?? true;
    _name = pp[UserModel.USERNAME] ?? "User";
    _phone = pp[UserModel.PHONENUMBER] ?? "";
    _town = pp[UserModel.ADDRESS] ?? "";
    _email = pp[UserModel.EMAIL] ?? "";
    _petCount = pp[PETCOUNT] ?? 0;
  }
}
