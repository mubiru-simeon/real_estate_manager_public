// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'thing_type.dart';
// import 'user.dart';

// class Booking {
//   static const DIRECTORY = "bookings";
//   static const ORDERTYPE = "orderType";

//   //service stuff
//   static const PRICEPERHOUR = "pricePerHour";
//   static const REMOTE = "remote";
//   static const TITLE = "title";
//   static const CUSTOMERTYPE = "customerType";
//   static const DATEMODE = "dateMode";
//   static const FLATRATE = "flatRate";
//   static const HOURCOUNT = "hourCount";
//   static const TASKERCOUNT = "taskerCount";
//   static const LOCATION = "location";
//   static const TIMESOFDAY = "timesOfDay";
//   static const DATEWHENSERVICEISNEEDED = "dateOfService";
//   static const DESCRIPTION = "description";

//   //booking stuff
//   static const START = "start";
//   static const PROPERTY = "property";
//   static const STOP = "stop";
//   static const APPROVED = "approved";
//   static const ONGOING = "ongoing";
//   static const CHECKEDIN = "checkedIn";
//   static const OWNER = "owner";
//   static const REJECTED = "rejected";
//   static const ADULTCOUNT = "adultCount";
//   static const CHILDCOUNT = "childCount";
//   static const PETCOUNT = "petCount";
//   static const PROPERTYPRICE = "propertyPrice";
//   static const CHECKERIN = "checkerIn";
//   static const DATEOFCHECKINGIN = "dateOfCheckingIn";
//   static const PAYMENTAMOUNT = "paymentAmount";
//   static const BUYER = "buyer";
//   static const DATEOFPAYMENT = "dateOfPayment";
//   static const OFFEREDROOMS = "offeredRooms";
//   static const SELECTEDROOMS = "selectedRooms";
//   static const LUGGAGE = "luggage";
//   static const CHECKEDINGUESTS = "checkedInGuests";
//   static const INEEDALIFT = "needALift";

//   static const MORNING = "morning";
//   static const EVENING = "evening";
//   static const MIDDAY = "midday";
//   static const AFTERNOON = "afternoon";

//   static const PACKAGES = "packages";
//   static const PRICE = "price";
//   static const CUSTOMERS = "customers";
//   static const DELIVERY = "delivery";
//   static const LONG = "long";
//   static const PAYMENTID = "paymentID";
//   static const SERVICEPROVIDER = "serviceProvider";
//   static const LAT = "lat";
//   static const THINGID = "thingID";
//   static const DATE = "date";
//   static const PENDING = "pending";
//   static const COMPLETE = "complete";
//   static const CANCELLED = "cancelled";
//   static const VARIATIONS = "variations";
//   static const SIZES = "sizes";
//   static const DELIVERING = "delivering";
//   static const IMAGES = "images";
//   static const GIFTDELIVERYDETAILS = "giftDeliveryDetails";
//   static const COLLECTION = "collection";
//   static const RECEPIENT = "recepient";
//   static const MESSAGE = "message";
//   static const TIMEOFCHECKIN = "timeOfCheckIn";
//   static const GIFTBAG = "giftbag";

//   //food stuff
//   static const AMOUNT = "amount";
//   static const RANDOMIZE = "randomize";
//   static const MONEY = "money";

//   //string stuff
//   List _timesNeeded;
//   int _flatRate;
//   bool _remote;
//   int _hourCount;
//   int _pricePerHour;

// //booking stuff
//   int _adultCount;
//   Map _offeredRooms;
//   int _petCount;
//   bool _checkedIn;
//   int _childrenCount;
//   String _title;
//   String _desc;
//   bool _luggage;
//   bool _pickUp;
//   List _selectedRooms;
//   int _dateOfCheckIn;
//   String _property;
//   int _start;
//   int _stop;
//   bool _approved;
//   bool _pending;

// //ticket stuff
//   String _buyer;
//   int _checkInTime;
//   String _paymentID;
//   String _perText;
//   int _date;
//   List _customers;
//   String _type;
//   String _email;
//   String _phone;
//   List _serviceProviders;
//   dynamic _totalTicketCount;
//   int _checkedInGuests;
//   int _ticketsLeft;
//   String _checkerIn;
//   String _name;
//   String _thingID;
//   String _id;

//   bool _delivery;
//   double _lat;
//   bool _delivering;
//   double _long;
//   dynamic _packages;
//   int _timeOfPurchase;
//   bool _purchaseComplete;
//   bool _purchasePending;
//   bool _purchaseCancelled;
//   List<String> _variations;
//   List<String> _sizes;
//   List<dynamic> _images;
//   String _giftDeliveryDetails;
//   String _collection;
//   String _recepient;
//   String _message;

//   //service stuff
//   String get title => _title;
//   bool get remote => _remote;
//   String get desc => _desc;

//   List get timesNeeded => _timesNeeded;
//   int get flatRate => _flatRate;
//   int get hourCount => _hourCount;
//   int get pricePerHour => _pricePerHour;

//   //booking stufff
//   bool get checkedIn => _checkedIn;
//   int get dateOfCheckIn => _dateOfCheckIn;
//   bool get pending => _pending;
//   String get property => _property;
//   bool get luggage => _luggage;
//   bool get pickup => _pickUp;
//   String get paymentID => _paymentID;
//   int get petCount => _petCount;
//   List get selectedRooms => _selectedRooms;
//   int get adultCount => _adultCount;
//   int get childCount => _childrenCount;
//   Map get offeredRooms => _offeredRooms;
//   bool get approved => _approved;
//   int get start => _start;
//   int get stop => _stop;
//   int get timeOfPurchase => _timeOfPurchase;

// //ticket stuff
//   String get perText => _perText;
//   int get ticketsLeft => _ticketsLeft;
//   String get type => _type;
//   String get checkerIn => _checkerIn;
//   int get checkInTime => _checkInTime;
//   dynamic get ticketCount => _totalTicketCount;
//   String get id => _id;
//   List get serviceProviders => _serviceProviders;
//   int get date => _date;
//   List get customers => _customers;
//   String get thingID => _thingID;
//   String get buyer => _buyer;
//   String get email => _email;
//   int get guestsCheckedIn => _checkedInGuests;
//   String get phone => _phone;
//   String get name => _name;

//   List<dynamic> get variations => _variations;
//   List<dynamic> get sizes => _sizes;
//   List<dynamic> get images => _images;
//   bool get delivering => _delivering;
//   String get collection => _collection;
//   String get recepient => _recepient;
//   String get message => _message;
//   bool get delivery => _delivery;
//   double get lat => _lat;
//   double get long => _long;
//   String get deliveryDetails => _giftDeliveryDetails;
//   dynamic get packages => _packages;

//   bool get purchasePending => _purchasePending;
//   bool get cancelled => _purchaseCancelled;
//   bool get purchaseComplete => _purchaseComplete;

//   Booking.fromSnapshot(DocumentSnapshot snapshot) {
//     Map pp = snapshot.data() as Map;

//     //service stuff
//     _title = pp[TITLE];
//     _remote = pp[REMOTE] ?? false;
//     _desc = pp[DESCRIPTION];
//     _flatRate = pp[FLATRATE] ?? 0;
//     _pricePerHour = pp[PRICEPERHOUR] ?? 0;
//     _hourCount = pp[HOURCOUNT] ?? 0;
//     _timesNeeded = pp[TIMESOFDAY] ?? [];

//     //booking stuff
//     _timeOfPurchase = pp[DATE];
//     _approved = pp[APPROVED];
//     _pending = pp[PENDING];
//     _property = pp[PROPERTY];
//     _pickUp = pp[INEEDALIFT] ?? false;
//     _dateOfCheckIn = pp[DATEOFCHECKINGIN];
//     _luggage = pp[LUGGAGE] ?? true;
//     _paymentID = pp[PAYMENTID];
//     _selectedRooms = pp[SELECTEDROOMS];
//     _id = snapshot.id;
//     _childrenCount = pp[CHILDCOUNT] ?? 0;
//     _offeredRooms = pp[OFFEREDROOMS] ?? {};
//     _checkedIn = pp[CHECKEDIN] ?? false;
//     _adultCount = pp[ADULTCOUNT] ?? 0;
//     _petCount = pp[PETCOUNT] ?? 0;
//     _start = pp[START] ?? DateTime.now().millisecondsSinceEpoch;
//     _stop = pp[STOP] ?? _start;
//     _pending = pp[PENDING];

//     //ticket stuff
//     _thingID = pp[THINGID];
//     _buyer = pp[BUYER];
//     _id = snapshot.id;
//     _checkInTime = pp[TIMEOFCHECKIN];
//     _checkedInGuests = pp[CHECKEDINGUESTS] ?? 0;
//     _checkerIn = pp[CHECKERIN];
//     _name = pp[UserModel.USERNAME];
//     _type = pp[ORDERTYPE] ?? ThingType.PROPERTY;
//     _message = pp[MESSAGE];
//     _serviceProviders = pp[SERVICEPROVIDER] ?? [];
//     _email = pp[UserModel.EMAIL];
//     _phone = pp[UserModel.PHONENUMBER];
//     _paymentID = pp[PAYMENTID];
//     _date = pp[DATE] ?? DateTime.now().millisecondsSinceEpoch;
//     _customers = pp[CUSTOMERS] ?? [];
//     dynamic p = 0;

//     _totalTicketCount = p;

//     _ticketsLeft = _totalTicketCount - _checkedInGuests;

//     _images = pp[IMAGES] ?? [];
//     _collection = pp[COLLECTION];
//     _recepient = pp[RECEPIENT];
//     _message = pp[MESSAGE];
//     _variations = pp[VARIATIONS] ?? [];
//     _sizes = pp[SIZES] ?? [];
//     _giftDeliveryDetails = pp[GIFTDELIVERYDETAILS];

//     _delivery = pp[DELIVERY] ?? false;
//     _lat = pp[LAT] ?? 00;
//     _paymentID = pp[PAYMENTID];
//     _long = pp[LONG] ?? 00;
//     _id = snapshot.id;
//     _delivering = pp[DELIVERING] ?? false;
//     _packages = pp[PACKAGES] ?? {};
//     _timeOfPurchase = pp[DATE];
//     _purchaseComplete = pp[COMPLETE] ?? false;
//     _purchasePending = pp[PENDING] ?? true;
//     _purchaseCancelled = pp[CANCELLED] ?? false;
//   }
// }
