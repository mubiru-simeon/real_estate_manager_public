import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'widgets.dart';

class AttachRoomsToBookingBottomSheet extends StatefulWidget {
  final Booking booking;
  final bool updating;
  AttachRoomsToBookingBottomSheet({
    Key key,
    @required this.booking,
    @required this.updating,
  }) : super(key: key);

  @override
  State<AttachRoomsToBookingBottomSheet> createState() =>
      _AttachRoomsToBookingBottomSheetState();
}

class _AttachRoomsToBookingBottomSheetState
    extends State<AttachRoomsToBookingBottomSheet> {
  @override
  void initState() {
    super.initState();
  }

  Map selectedRooms = {};
  PageController pageController = PageController();
  int _currentIndex = 0;
  TextEditingController priceController = TextEditingController();
  bool processing = false;
  bool showCustomPrice = false;
  bool tipVisible = true;
  List<Widget> pages;
  double calculatedTotalPrice = 0;

  @override
  Widget build(BuildContext context) {
    pages = [
      attachRoom(),
      pricePage(),
    ];

    return WillPopScope(
      onWillPop: () {
        return handleBackButton();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              BackBar(
                  icon: _currentIndex == 0 ? Icons.close : null,
                  onPressed: _currentIndex == 0
                      ? null
                      : () {
                          goBack();
                        },
                  text: "Add New Property",
                  action: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ColorMeaningDialogBox();
                        },
                      );
                    },
                    icon: Icon(
                      Icons.help,
                    ),
                  )),
              Row(
                children: pages.map((e) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 1,
                      ),
                      height: 5,
                      color: _currentIndex >= pages.indexOf(e)
                          ? primaryColor
                          : Colors.grey,
                    ),
                  );
                }).toList(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    onPageChanged: (v) {
                      setState(() {
                        _currentIndex = v;
                      });
                    },
                    controller: pageController,
                    children: pages.map((e) => e).toList(),
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Row(
                children: [
                  Expanded(
                    child: ProceedButton(
                      onTap: () {
                        checkIfItsSafeToProceed();
                      },
                      processing: processing,
                      enablable: false,
                      borderRadius: standardBorderRadius,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentIndex == pages.length - 1
                                ? "Submit Property"
                                : "Proceed",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  pricePage() {
    return Column(
      children: [
        HeadLineText(
          onTap: null,
          plain: true,
          text: "How much should the client pay?",
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "The Price we've calculated: ${TextService().putCommas(calculatedTotalPrice.toString())} UGX",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        CustomDivider(),
        CheckboxListTile(
          title: Text(
            "I want to set my own custom price",
          ),
          value: showCustomPrice,
          onChanged: (v) {
            setState(() {
              showCustomPrice = v;
            });
          },
        ),
        CustomDivider(),
        SizedBox(
          height: 10,
        ),
        if (showCustomPrice)
          Text(
            "You can set your own price for this booking if you want. Please keep in mind that guests have a lot of options, so do not make your price too crazy.",
          ),
        if (showCustomPrice)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    hintText: "Price",
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "UGX",
              ),
            ],
          )
      ],
    );
  }

  checkIfItsSafeToProceed() {
    if (_currentIndex == 0 && selectedRooms.isEmpty) {
      CommunicationServices().showSnackBar(
        "Please select some room(s) for this guest.",
        context,
      );
    } else {
      if (_currentIndex == 1 && priceController.text.trim().isEmpty) {
        CommunicationServices().showSnackBar(
          "Please provide the price for this booking.",
          context,
        );
      } else {
        if (_currentIndex == pages.length - 1) {
          if (AuthProvider.of(context).auth.isSignedIn()) {
            showPreApprovalDialogBox();
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return NotLoggedInDialogBox(
                  onLoggedIn: () {
                    showPreApprovalDialogBox();
                  },
                );
              },
            );
          }
        } else {
          goNext();
        }
      }
    }
  }

  showPreApprovalDialogBox() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialogBox(
          bodyText:
              "PLEASE NOTE: By pressing this button, you're approving the booking, and the guest will be expecting to find that room booked and prepared for them.\n\nExpect your payment soon.",
          buttonText: "I Understand",
          onButtonTap: () {
            updateBooking();
          },
          showOtherButton: true,
        );
      },
    );
  }

  updateBooking() async {
    setState(() {
      processing = true;
    });

    if (widget.updating) {
      for (var item in widget.booking.offeredRooms.entries) {
        FirebaseFirestore.instance
            .collection(Room.DIRECTORY)
            .doc(item.key)
            .get()
            .then((value) {
          Room rm = Room.fromSnapshot(value);

          Map roomDates = rm.dates ?? {};
          roomDates.remove(widget.booking.id);

          FirebaseFirestore.instance
              .collection(Room.DIRECTORY)
              .doc(item.key)
              .update({
            Room.DATES: roomDates,
          }).catchError((n) {
            setState(() {
              processing = false;
            });

            CommunicationServices().showToast(
              "There was an error updating room data: $n.",
              Colors.green,
            );
          });
        });
      }
    }

    Map pp = {};

    for (var item in selectedRooms.entries) {
      pp.addAll({
        item.key: {
          Room.ROOMTYPE: item.value[Room.ROOMTYPE],
          RoomType.PRICE: item.value[RoomType.PRICE],
        }
      });

      Map gh = {};

      item.value[Room.DATES].forEach((k, v) {
        gh.addAll({k: v});
      });

      gh.addAll({
        widget.booking.id: {
          Room.START: widget.booking.start,
          Room.STOP: widget.booking.stop,
        }
      });

      await FirebaseFirestore.instance
          .collection(Room.DIRECTORY)
          .doc(item.key)
          .update({
        Room.DATES: gh,
      }).catchError((n) {
        setState(() {
          processing = false;
        });

        CommunicationServices().showToast(
          "There was an error updating room data: $n.",
          Colors.green,
        );
      });
    }

    if (processing) {
      await FirebaseFirestore.instance
          .collection(Booking.DIRECTORY)
          .doc(widget.booking.id)
          .update(
        {
          Booking.PENDING: true,
          Booking.OFFEREDROOMS: pp,
          Booking.APPROVED: true,
          Booking.PAYMENTAMOUNT: showCustomPrice
              ? double.parse(
                  priceController.text.trim(),
                )
              : calculatedTotalPrice,
        },
      ).then((value) {
        Navigator.of(context).pop();

        CommunicationServices().showToast(
          "The Booking has been updated.",
          Colors.green,
        );
      }).timeout(Duration(seconds: 10), onTimeout: () {
        setState(() {
          processing = false;
        });

        CommunicationServices().showToast(
          "There was an issue updating the booking. Check your internet connection.",
          Colors.green,
        );
      }).catchError(
        (b) {
          setState(() {
            processing = false;
          });

          CommunicationServices().showToast(
            "There was an error updating the booking: $b",
            Colors.green,
          );
        },
      );
    }
  }

  goNext() {
    pageController.animateToPage(
      (pageController.page + 1).toInt(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  goBack() {
    pageController.animateToPage(
      (pageController.page - 1).toInt(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  handleBackButton() {
    if (_currentIndex != 0) {
      goBack();
    } else {
      Navigator.of(context).pop();
    }
  }

  attachRoom() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                CustomDivider(),
                ListTile(
                  leading: Icon(
                    FontAwesomeIcons.peopleArrows,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Adults: ${widget.booking.adultCount} people",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Children: ${widget.booking.childCount} children",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Pets: ${widget.booking.petCount} pets",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.booking.luggage)
                        Text(
                          "The guest also has some luggage too",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                CustomDivider(),
                InformationalBox(
                  visible: tipVisible,
                  onClose: () {
                    setState(() {
                      tipVisible = false;
                    });
                  },
                  message:
                      "Here, you're supposed to provide some rooms to the booking, based on what the guest needs.\nIncase You're feeling a little confused about the colors, feel free to tap the question mark icon up there.",
                )
              ]
                  .followedBy(
                    widget.booking.selectedRooms.map<Widget>(
                      (e) => singleRoomTypeThing(
                        e,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: selectedRooms.entries
                .map<Widget>(
                  (e) => SingleRoom(
                    room: null,
                    onRemoveRoom: () {
                      setState(() {
                        selectedRooms.remove(
                          e.key,
                        );
                      });
                    },
                    horizontal: true,
                    roomID: e.key,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  singleRoomTypeThing(
    String roomID,
  ) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(RoomType.DIRECTORY)
            .doc(roomID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoadingWidget();
          } else {
            RoomType roomType = RoomType.fromSnapshot(snapshot.data);

            return Container(
              padding: EdgeInsets.all(2),
              margin: EdgeInsets.all(3),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: standardBorderRadius),
              child: Column(
                children: [
                  Row(
                    children: [
                      SingleRoomType(
                        horizontal: true,
                        simple: true,
                        roomType: roomType,
                        width: MediaQuery.of(context).size.width * 0.3,
                        roomTypeID: roomID,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: PaginateFirestore(
                            query: FirebaseFirestore.instance
                                .collection(
                                  Room.DIRECTORY,
                                )
                                .where(
                                  Room.ROOMTYPE,
                                  isEqualTo: roomID,
                                ),
                            scrollDirection: Axis.horizontal,
                            isLive: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            itemBuilder: (context, snapshot, index) {
                              Room room = Room.fromSnapshot(snapshot[index]);

                              return SingleRoomContainer(
                                room: room,
                                onTap: () {
                                  if (selectedRooms.containsKey(room.id)) {
                                    setState(() {
                                      selectedRooms.remove(room.id);

                                      calculatedTotalPrice =
                                          calculatedTotalPrice - roomType.price;

                                      priceController = TextEditingController(
                                        text: calculatedTotalPrice.toString(),
                                      );
                                    });
                                  } else {
                                    setState(
                                      () {
                                        selectedRooms.addAll(
                                          {
                                            room.id: {
                                              Room.ROOMTYPE: room.roomType,
                                              Room.DATES: room.dates,
                                              RoomType.PRICE: roomType.price,
                                            }
                                          },
                                        );

                                        calculatedTotalPrice =
                                            calculatedTotalPrice +
                                                roomType.price;

                                        priceController = TextEditingController(
                                          text: calculatedTotalPrice.toString(),
                                        );
                                      },
                                    );
                                  }
                                },
                                propertyID: widget.booking.property,
                                longPressable: true,
                                selected: selectedRooms.containsKey(room.id),
                                startDate: widget.booking.start,
                                stopDate: widget.booking.stop,
                              );
                            },
                            itemBuilderType: PaginateBuilderType.gridView,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Long Press on a room to see details.\nTap on a room to select it.",
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            );
          }
        });
  }
}

class ColorMeaningDialogBox extends StatefulWidget {
  ColorMeaningDialogBox({Key key}) : super(key: key);

  @override
  State<ColorMeaningDialogBox> createState() => _ColorMeaningDialogBoxState();
}

class _ColorMeaningDialogBoxState extends State<ColorMeaningDialogBox> {
  @override
  Widget build(BuildContext context) {
    return CustomDialogBox(
      bodyText: "",
      buttonText: "Here",
      onButtonTap: () {},
      showOtherButton: true,
      child: Column(
        children: [
          Text(
            "This is what the colors mean.",
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            children: roomColors.entries
                .map<Widget>(
                  (e) => Container(
                    decoration: BoxDecoration(
                        borderRadius: standardBorderRadius,
                        border: Border.all(
                          color: Colors.grey,
                        )),
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: e.value,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            e.key == RoomAvailability.available
                                ? "The Room is Available. No bookings overlap the selected booking."
                                : e.key == RoomAvailability.occupied
                                    ? "The room is occupied by someone (Or, the selected booking completely overlaps with a booking of this room in that time frame)"
                                    : "Please tap here to view the current booking and make a decision.",
                          ),
                        )
                      ],
                    ),
                  ),
                )
                .toList(),
          )
        ],
      ),
    );
  }
}

class SingleRoomContainer extends StatelessWidget {
  final Room room;
  final String propertyID;
  final int startDate;
  final bool selected;
  final Function onTap;
  final bool longPressable;
  final int stopDate;
  const SingleRoomContainer({
    Key key,
    @required this.room,
    @required this.propertyID,
    this.onTap,
    this.selected = false,
    this.startDate,
    this.longPressable = false,
    this.stopDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RoomAvailability rA = room.available(startDate, stopDate);

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        } else {
          UIServices().showDatSheet(
            RoomDetailsBottomSheet(
              roomID: room.id,
              propertyID: propertyID,
            ),
            true,
            context,
          );
        }
      },
      onLongPress: () {
        if (longPressable) {
          UIServices().showDatSheet(
            RoomDetailsBottomSheet(
              roomID: room.id,
              propertyID: propertyID,
            ),
            true,
            context,
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 2,
        ),
        padding: EdgeInsets.all(selected ? 5 : 0),
        decoration: BoxDecoration(
            border: selected
                ? Border.all(
                    color: Colors.grey,
                  )
                : null,
            borderRadius: standardBorderRadius),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: standardBorderRadius,
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
            color: getRoomColorFromAvailability(context, rA).withOpacity(0.8),
          ),
          child: Center(
            child: Text(
              room.roomNumber.toUpperCase(),
              style: TextStyle(
                color: rA != RoomAvailability.tapHereToCheckBro
                    ? Colors.white
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
