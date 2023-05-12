import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class HandleBookingView extends StatefulWidget {
  final String bookingID;

  const HandleBookingView({
    Key key,
    @required this.bookingID,
  }) : super(key: key);

  @override
  State<HandleBookingView> createState() => _HandleBookingViewState();
}

class _HandleBookingViewState extends State<HandleBookingView> {
  bool callProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackBar(
              icon: null,
              onPressed: null,
              text: "Handle a booking",
            ),
            Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(Booking.DIRECTORY)
                        .doc(widget.bookingID)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return LoadingWidget();
                      } else {
                        Booking appointment =
                            Booking.fromSnapshot(snapshot.data);

                        return body(
                          appointment,
                        );
                      }
                    }))
          ],
        ),
      ),
    );
  }

  serviceRow(
    String text,
    dynamic content,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 5,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  text.toString(),
                  style: darkTitle,
                ),
              ),
              Expanded(
                child: Text(
                  content.toString(),
                ),
              ),
            ],
          ),
          CustomDivider(),
        ],
      ),
    );
  }

  body(
    Booking appointment,
  ) {
    List<TableRow> children = [
      _buildRow(
        [
          "Customer Details",
          "",
        ],
        true,
      ),
    ];

    //--------------customer details--------------------
    children.add(
      _buildRow(
        [
          "Client Name",
          appointment.name,
        ],
        false,
      ),
    );
    children.add(
      appointment.phone != null && appointment.phone.trim().isNotEmpty
          ? _buildRow(
              [
                "Telephone",
                appointment.phone,
              ],
              false,
            )
          : appointment.customer != null
              ? _buildRow(
                  null,
                  false,
                  word: "Telephone",
                  widget: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection(UserModel.DIRECTORY)
                          .doc(appointment.customer)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return LoadingWidget();
                        } else {
                          UserModel user = UserModel.fromSnapshot(
                            snapshot.data,
                            Provider.of<PropertyManagement>(context)
                                .getCurrentPropertyID(),
                          );

                          return Text(
                            user.phoneNumber ?? "No phone number",
                          );
                        }
                      },
                    ),
                  ),
                )
              : _buildRow(
                  [
                    "Telephone",
                    "",
                  ],
                  false,
                ),
    );
    children.add(
      _buildRow(
        [
          "Email",
          appointment.email,
        ],
        false,
      ),
    );
    children.add(
      _buildRow(
        [
          "Address",
          appointment.town,
        ],
        false,
      ),
    );

    children.add(
      _buildRow(
        [
          "Requested Rooms",
          "",
        ],
        true,
      ),
    );
    for (var v in appointment.roomsRequested) {
      children.add(
        _buildRow([
          "Room",
          "",
        ], true,
            widget: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(RoomType.DIRECTORY)
                    .doc(v)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return LoadingWidget();
                  } else {
                    RoomType serviceModel =
                        RoomType.fromSnapshot(snapshot.data);

                    return Column(
                      children: [
                        serviceRow(
                          "Name",
                          serviceModel.name,
                        ),
                        serviceRow(
                          "Description",
                          serviceModel.description,
                        ),
                        serviceRow(
                          "Price",
                          "${TextService().putCommas(serviceModel.price.toString())} UGX",
                        ),
                        serviceRow(
                          "Rate",
                          serviceModel.paymentFrequency,
                        ),
                      ],
                    );
                  }
                })),
      );
    }

    children.add(
      _buildRow(
        [
          "Other details",
          "",
        ],
        true,
      ),
    );

    children.add(
      _buildRow(
        [
          "From",
          DateService().dateFromMilliseconds(
            appointment.start,
          ),
        ],
        false,
      ),
    );
    children.add(
      _buildRow(
        [
          "To",
          DateService().dateFromMilliseconds(
            appointment.stop,
          ),
        ],
        false,
      ),
    );
    children.add(
      _buildRow(
        [
          "Date Ordered",
          "${DateService().dateFromMilliseconds(
            appointment.date,
          )} at ${DateService().getTimeInAmPm(
            DateTime.fromMillisecondsSinceEpoch(appointment.date).hour,
            DateTime.fromMillisecondsSinceEpoch(appointment.date).minute,
          )}",
        ],
        false,
      ),
    );
    children.add(
      _buildRow(
        [
          "Adults",
          TextService().putCommas(
            appointment.adultCount.toString(),
          ),
        ],
        false,
      ),
    );
    children.add(
      _buildRow(
        [
          "Children",
          TextService().putCommas(
            appointment.childCount.toString(),
          ),
        ],
        false,
      ),
    );
    children.add(
      _buildRow(
        [
          "Pets (excluding service animals)",
          TextService().putCommas(
            appointment.petCount.toString(),
          ),
        ],
        false,
      ),
    );
    if (appointment.luggage) {
      children.add(
        _buildRow(
          [
            "Luggage",
            appointment.luggage ? "The customer has some luggage" : "No luggage"
          ],
          false,
        ),
      );
    }
    if (appointment.needALift) {
      children.add(
        _buildRow(
          [
            "Pickup and Delivery",
            appointment.needALift
                ? "The customer will be picked and delivered to your place by $capitalizedAppName team, if you approve this booking."
                : "No pickup"
          ],
          false,
        ),
      );
    }
    children.add(
      _buildRow(
        [
          "Auto Code",
          appointment.id,
        ],
        true,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Table(
              border: TableBorder.all(),
              children: children,
            ),
            SizedBox(
              height: 20,
            ),
            Wrap(
              children: {
                "Call": {
                  "color": primaryColor,
                  "onTap": () {
                    if (appointment.customer == null) {
                      launchUrl(Uri.parse("tel:${appointment.phone}"));
                    } else {
                      setState(() {
                        callProcessing = true;
                      });

                      FirebaseFirestore.instance
                          .collection(UserModel.DIRECTORY)
                          .doc(appointment.customer)
                          .get()
                          .then((value) {
                        UserModel userModel = UserModel.fromSnapshot(
                          value,
                          Provider.of<PropertyManagement>(context)
                              .getCurrentPropertyID(),
                        );

                        setState(() {
                          callProcessing = false;
                        });

                        if (userModel.phoneNumber == null) {
                          CommunicationServices().showToast(
                            "The user doesn't have a phone number attached to his account. Contact the IT Manager for help.",
                            Colors.red,
                          );
                        } else {
                          launchUrl(Uri.parse("tel:${userModel.phoneNumber}"));
                        }
                      }).timeout(
                              Duration(
                                seconds: 10,
                              ), onTimeout: () {
                        setState(() {
                          callProcessing = false;
                        });

                        CommunicationServices().showToast(
                          "There was an error connecting to the server. Check your internet connection and try again.",
                          Colors.red,
                        );
                      });
                    }
                  },
                },
                if (appointment.pending)
                  "Mark Completed": {
                    "color": Colors.green,
                    "onTap": () {
                      FirebaseFirestore.instance
                          .collection(Booking.DIRECTORY)
                          .doc(appointment.id)
                          .update(
                        {
                          Booking.PENDING: false,
                          Booking.ONGOING: false,
                          Booking.COMPLETE: true,
                        },
                      ).then((value) {
                        CommunicationServices().showSnackBar(
                          "Successfully finished the Panic Button Event.",
                          context,
                        );
                      });
                    }
                  },
                // if (appointment.paymentID == null)
                //   "Mark Paid": {
                //     "color": Colors.indigo,
                //     "onTap": () {
                //       String uid =
                //           AuthProvider.of(context).auth.getCurrentUID();

                //       showDialog(
                //         context: context,
                //         builder: (context) {
                //           return CustomDialogBox(
                //             bodyText:
                //                 "Do you really want to mark this appointment as paid for in Cash?",
                //             buttonText: "Do it",
                //             onButtonTap: () {
                //               StorageServices().paySomeone(
                //                 appointment.total,
                //                 false,
                //                 appointment.customer ?? ThingType.ADMIN,
                //                 ADMIN,
                //                 appointment.id,
                //                 Payment.SERVICEPAYMENT,
                //                 ThingType.APPOINTMENT,
                //                 appointment.customer == null
                //                     ? ThingType.ADMIN
                //                     : ThingType.USER,
                //                 ThingType.ADMIN,
                //                 false,
                //                 false,
                //                 CASH,
                //                 after: (v) {
                //                   FirebaseFirestore.instance
                //                       .collection(Booking.DIRECTORY)
                //                       .doc(appointment.id)
                //                       .update(
                //                     {
                //                       Booking.PAYMENTID: v,
                //                       Booking.CASHRECEPIENT: uid,
                //                     },
                //                   );
                //                 },
                //               );
                //             },
                //             showOtherButton: true,
                //           );
                //         },
                //       );
                //     }
                //   },
                if (appointment.complete == false &&
                    appointment.cancelled == false)
                  "Cancel": {
                    "color": Colors.red,
                    "onTap": () {
                      String uid =
                          AuthProvider.of(context).auth.getCurrentUID();

                      showDialog(
                          context: context,
                          builder: (context) {
                            return CustomDialogBox(
                              bodyText: "Are you sure this client cancelled?",
                              buttonText: "Yep. I'm sure",
                              onButtonTap: () {
                                FirebaseFirestore.instance
                                    .collection(Booking.DIRECTORY)
                                    .doc(appointment.id)
                                    .update(
                                  {
                                    Booking.CANCELLED: true,
                                    Booking.PENDING: false,
                                    Booking.ONGOING: false,
                                    Booking.COMPLETE: false,
                                    Booking.CANCELLER: uid,
                                  },
                                );
                              },
                              showOtherButton: true,
                            );
                          });
                    }
                  }
              }
                  .entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.all(2),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: e.value["color"],
                        ),
                        onPressed: e.value["onTap"],
                        child: Text(
                          e.key,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildRow(
    List<String> text,
    bool darken, {
    Widget widget,
    String word,
  }) {
    return TableRow(
      children: widget == null
          ? text
              .map(
                (e) => Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    e ?? "",
                    style: TextStyle(
                      fontWeight: darken ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              )
              .toList()
          : [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  word ?? "",
                  style: TextStyle(
                    fontWeight: darken ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              widget,
            ],
    );
  }
}
