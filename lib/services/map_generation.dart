import '../models/models.dart';
import 'sq_lite_services.dart';

class MapGeneration {
  generateUserMap(
    UserModel user,
    String adder, {
    String propertyID,
  }) {
    return {
      UserModel.ADDRESS: user.address,
      UserModel.GENDER: user.gender,
      UserModel.IMAGES: user.images,
      UserModel.WHATSAPPNUMBER: user.whatsappNumber,
      UserModel.PHONENUMBER: user.phoneNumber,
      UserModel.TIMEOFJOINING: DateTime.now().millisecondsSinceEpoch,
      UserModel.USERNAME: user.userName,
      UserModel.PROFILEPIC: user.profilePic,
      UserModel.REGISTERER: adder,
      UserModel.REFEREES: user.referees,
      UserModel.EMAIL: user.email,
      ThingType.ADMIN: user.type == ThingType.ADMIN,
      ThingType.PROPERTYMANAGER: user.type == ThingType.PROPERTYMANAGER,
      if (propertyID != null)
        UserModel.AFFILIATION: [
          propertyID,
        ]
    };
  }

  generateSearchHistoryMap(String text) {
    return {
      SearchHistoryDBServices.SEARCHHISTORYTEXT: text,
      SearchHistoryDBServices.TIMESEARCHED:
          DateTime.now().millisecondsSinceEpoch,
    };
  }

  generateNotificationMap(NotificationModel not) {
    return {
      NotificationModel.TITLE: not.title,
      NotificationModel.BODY: not.body,
      NotificationModel.TIME: not.time,
      NotificationModel.THINGID: not.primaryId,
      NotificationModel.THINGTYPE: not.thingType,
    };
  }
}
