import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' as fdb;
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import 'services.dart';

class StorageServices {
  Future<String> getDynamicLink(
    String thingID,
    String thingType,
  ) async {
    String deepLinkUrl = "$deepLinkPrefix/$thingType/$thingID";
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(deepLinkUrl),
      uriPrefix: deepLinkPrefix,
      androidParameters: AndroidParameters(
        packageName: "com.dorx.real_estate_manager",
        fallbackUrl: Uri.parse(deepLinkUrl),
      ),
    );

    return (await FirebaseDynamicLinks.instance.buildShortLink(
      dynamicLinkParams,
      shortLinkType: ShortDynamicLinkType.unguessable,
    ))
        .shortUrl
        .toString();
  }

  Future<bool> checkIfEmailInUse(String emailAddress) async {
    try {
      // Fetch sign-in methods for the email address
      final list =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);

      if (list.isNotEmpty) {
        // Return true because there is an existing
        // user using the email address
        return true;
      } else {
        // Return false because email adress is not in use
        return false;
      }
    } catch (error) {
      CommunicationServices().showToast(
        "Error looking up email: $error",
        Colors.red,
      );

      return true;
    }
  }

  paySomeone(
    double amount,
    bool withdrawal,
    String sender,
    String recepient,
    String thingID,
    String paymentReason,
    String type,
    String senderType,
    String recepientType,
    bool increaseRecepient,
    bool decreaseSender,
    bool deposit,
    String selectedMode,
    bool entityWallet,
    String entity,
    String entityType,
  ) {
    FirebaseFirestore.instance.collection(Payment.DIRECTORY).add({
      Payment.AMOUNT: amount,
      Payment.WITHDRAWAL: withdrawal,
      Payment.TIME: DateTime.now().millisecondsSinceEpoch,
      Payment.DEPOSIT: deposit,
      Payment.SENDER: sender,
      Payment.ENTITYWALLET: entityWallet,
      Payment.SENDERTYPE: senderType,
      Payment.RECEPIENT: recepient,
      Payment.DECREASESENDER: selectedMode == WALLET && deposit != true,
      Payment.MONEYSOURCE: selectedMode,
      Payment.RECEPIENTTYPE: recepientType,
      Payment.ENTITY: entity,
      Payment.ENTITYTYPE: entityType,
      Payment.INCREASERECEPIENT: selectedMode != CASH && increaseRecepient,
      Payment.THINGID: thingID,
      Payment.THINGTYPE: type,
      Payment.PAYMENTREASON: paymentReason,
      Payment.PARTICIPANTS: [
        sender,
        recepient,
      ],
    });
  }

  String getEmailLink(
    String email,
    String header,
    String body,
  ) {
    return "mailto:$email?subject=$header&body=$body";
  }

  launchSocialLink(
    String link,
    String lead,
  ) {
    String top;
    if (lead.startsWith("@")) {
      top = link.replaceFirst(RegExp(r'@'), "");

      top = "$lead$top";
    } else {
      if (link.startsWith("www")) {
        top = link;
      } else {
        top = lead;
      }
    }

    StorageServices().launchTheThing(top);
  }

  launchTheThing(String uri) {
    launchUrl(
      Uri.parse(uri),
      mode: LaunchMode.externalApplication,
    );
  }

  handleClick(
    String type,
    String id,
    BuildContext context,
  ) async {}

  increaseAnalytics(
    String date,
    String ss,
    String type,
    String ff,
  ) {}

  handleLocationStuffForItems(
    double lat,
    double long,
    String thingID,
    String country,
    String city,
    String address,
    String directory,
  ) async {
    if (country != null) {
      FirebaseFirestore.instance.collection(directory).doc(thingID).update(
        {
          GeoHashedItem.ADDRESS: address,
          GeoHashedItem.COUNTRY: country,
          GeoHashedItem.CITY: city,
        },
      );
    } else {
      GeoFirePoint geoFirePoint = Geoflutterfire().point(
        latitude: lat,
        longitude: long,
      );

      await LocationService().getAddressFromLatLng(LatLng(lat, long)).then(
        (value) {
          {
            if (value != null) {
              FirebaseFirestore.instance
                  .collection(directory)
                  .doc(thingID)
                  .update(
                {
                  GeoHashedItem.ADDRESS: value["text"],
                  GeoHashedItem.COUNTRY: value["pla"].country,
                  GeoHashedItem.CITY: value["pla"].locality,
                  GeoHashedItem.POSITION: geoFirePoint.data,
                },
              );
            }
          }
        },
      );
    }
  }

  int getPrice(String priceText, {double deMoney}) {
    int price = deMoney == null
        ? double.parse(priceText.trim()).toInt()
        : deMoney.toInt();

    int pricetoShow = price;

    return pricetoShow;
  }

  scanQRCode(
    String expectedType,
    Function(Map) whatToDo,
    BuildContext context,
  ) async {
    await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      "Cancel",
      true,
      ScanMode.QR,
    ).then((value) {
      if (value != null) {
        if (value.length <= 4) {
          CommunicationServices().showToast(
            "No data detected. Please try again.",
            Colors.red,
          );
        } else {
          Map pp = json.decode(value.toString());

          String type = pp[QRCodeScannerResult.THINGTYPE];
          String id = pp[QRCodeScannerResult.THINGID];

          if (expectedType != null && type != expectedType) {
            CommunicationServices().showToast(
              "Error Invalid QR Code: The QR Code scanned is for a $type.",
              Colors.red,
            );
          } else {
            if (whatToDo != null) {
              whatToDo(pp);
            } else {
              handleClick(
                type,
                id,
                context,
              );
            }
          }
        }
      } else {
        CommunicationServices().showToast(
          "No Data Provided. Please scan again.",
          Colors.red,
        );
      }
    });
  }

  Future<double> getEntityAccountBalance(
    String uid,
    String entity,
  ) async {
    double dd = 0;

    await fdb.FirebaseDatabase.instance
        .ref()
        .child(Payment.ACCOUNTBALANCEDIRECTORY)
        .child(uid)
        .child(entity)
        .child("balance")
        .get()
        .then((value) {
      if (value.exists) {
        dd = 0;
      } else {
        dd = double.parse(value.value.toString());
      }
    });

    return dd;
  }

  createNewUser({
    @required String phoneNumber,
    @required String email,
    @required String userName,
    @required String address,
    @required String gender,
    @required String uid,
    @required String whatsappNumber,
    @required String type,
    @required List images,
    @required List referees,
    String property,
    @required String registerer,
  }) {
    UserModel user = UserModel.fromData(
      phoneNumber: phoneNumber,
      type: type,
      username: userName,
      registerer: registerer,
      gender: gender,
      referees: referees,
      address: address,
      whatsappNumber: whatsappNumber,
      images: images,
      profilePic: images.isEmpty ? null : images[0],
      email: email,
    );

    if (uid != null) {
      FirebaseFirestore.instance
          .collection(UserModel.DIRECTORY)
          .doc(uid)
          .update(
            MapGeneration().generateUserMap(
              user,
              registerer,
            ),
          )
          .then(
        (value) {
          NotificationModel not = NotificationModel.fromData(
            uid,
            "Account Successfully updated",
            "You account has been successfully created. You are most welcome.",
            DateTime.now(),
          );

          FirebaseFirestore.instance
              .collection(NotificationModel.DIRECTORY)
              .doc(uid)
              .collection(uid)
              .add(
                MapGeneration().generateNotificationMap(
                  not,
                ),
              );

          if (email != null) {
            String path;
            email
                .split(RegExp(
              r"[.,@]",
            ))
                .forEach(
              (element) {
                if (path != null) {
                  path = "$path/${element.trim().toLowerCase()}";
                } else {
                  path = element.trim().toLowerCase();
                }
              },
            );

            fdb.FirebaseDatabase.instance
                .ref()
                .child(UserModel.ACCOUNTTYPES)
                .child(path)
                .child(type)
                .set(DateTime.now().millisecondsSinceEpoch);
          }
        },
      );
    } else {
      FirebaseFirestore.instance
          .collection(UserModel.DIRECTORY)
          .add(
            MapGeneration().generateUserMap(
              user,
              registerer,
              propertyID: property,
            ),
          )
          .then(
        (value) {
          NotificationModel not = NotificationModel.fromData(
            value.id,
            "Account Successfully created",
            "Your Dorx account has been successfully created. You are most welcome.",
            DateTime.now(),
          );

          FirebaseFirestore.instance
              .collection(NotificationModel.DIRECTORY)
              .doc(value.id)
              .collection(value.id)
              .add(
                MapGeneration().generateNotificationMap(
                  not,
                ),
              );

          if (email != null) {
            String path;
            email
                .split(RegExp(
              r"[.,@]",
            ))
                .forEach(
              (element) {
                if (path != null) {
                  path = "$path/${element.trim().toLowerCase()}";
                } else {
                  path = element.trim().toLowerCase();
                }
              },
            );

            fdb.FirebaseDatabase.instance
                .ref()
                .child(UserModel.ACCOUNTTYPES)
                .child(path)
                .child(type)
                .set(DateTime.now().millisecondsSinceEpoch);
          }
        },
      );
    }
  }

  removeFCMToken(String userID) {
    fdb.FirebaseDatabase.instance.ref().child(UserModel.FCMTOKENS).update({
      userID: null,
    });

    updateLastLogout(userID);
  }

  updateFCMToken(String userID, String token) {
    fdb.FirebaseDatabase.instance.ref().child(UserModel.FCMTOKENS).update(
      {
        userID: token,
      },
    );
  }

  updateLastLogin(String uid) {
    fdb.FirebaseDatabase.instance
        .ref()
        .child(UserModel.LASTLOGINTIME)
        .child(uid)
        .update({
      DateTime.now().millisecondsSinceEpoch.toString(): true,
    });
  }

  updateLastLogout(String uid) {
    fdb.FirebaseDatabase.instance
        .ref()
        .child(UserModel.LASTLOGOUTTIME)
        .child(uid)
        .update({
      DateTime.now().millisecondsSinceEpoch.toString(): true,
    });
  }

  notifyAboutLogin(
    String uid,
  ) {
    NotificationModel not = NotificationModel.fromData(
      uid,
      "New Login",
      "Your account has just been logged-in in the Dorx property manager app.",
      DateTime.now(),
    );

    sendInAppNotification(not);
  }

  sendInAppNotification(NotificationModel notificationModel) {
    FirebaseFirestore.instance
        .collection(NotificationModel.DIRECTORY)
        .doc(notificationModel.recepient)
        .collection(notificationModel.recepient)
        .add(
          MapGeneration().generateNotificationMap(
            notificationModel,
          ),
        );
  }
}
