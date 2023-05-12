import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'widgets.dart';

class AddNewRoomTypeBottomSheet extends StatefulWidget {
  final String propertyID;
  final RoomType roomType;
  AddNewRoomTypeBottomSheet({
    Key key,
    @required this.propertyID,
    @required this.roomType,
  }) : super(key: key);

  @override
  State<AddNewRoomTypeBottomSheet> createState() =>
      _AddNewRoomTypeBottomSheetState();
}

class _AddNewRoomTypeBottomSheetState extends State<AddNewRoomTypeBottomSheet> {
  TextEditingController nameController = TextEditingController();
  bool _selfContained = false;
  String randomID;
  bool processing = false;
  List images = [];
  String frequency = PERMONTH;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController bathroomController = TextEditingController();
  TextEditingController guestCountController = TextEditingController();
  TextEditingController roomNumberController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.roomType != null) {
      nameController = TextEditingController(
        text: widget.roomType.name,
      );

      descriptionController = TextEditingController(
        text: widget.roomType.description,
      );

      for (var element in widget.roomType.images) {
        images.add(element);
      }

      _selfContained = widget.roomType.selfContained;

      randomID = widget.roomType.id;

      guestCountController = TextEditingController(
        text: widget.roomType.totalGuestCount.toString(),
      );

      priceController = TextEditingController(
        text: widget.roomType.price.toString(),
      );

      frequency = widget.roomType.paymentFrequency;

      bathroomController = TextEditingController(
        text: widget.roomType.bathroomCount.toString(),
      );
    } else {
      randomID = "${Uuid().v4()}${widget.propertyID}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "Add New Room Type",
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    InformationalBox(
                      visible: true,
                      onClose: null,
                      message:
                          "Here's how it works. Assuming you're adding rooms for a hostel, an example room type can be \"Doubles\" (which takes 2 people). You can provide some display images and a short description, then you type in the individual room numbers eg c1, c2, c3 etc and tap on \"add room\" for each room number you add. Tell us the price for these doubles and how often this money is collected and voila! You're done.",
                    ),
                    StatisticText(
                      title: "Name",
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      controller: nameController,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    StatisticText(
                      title: "Description",
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 5,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ImagePickerWidget(
                      images: images,
                      noSliver: true,
                      pickImages: () async {
                        List pp = await ImageServices().pickImages(
                          context,
                        );

                        if (pp.isNotEmpty) {
                          for (var element in pp) {
                            images.add(element);
                          }
                        }
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomDivider(),
                    CheckboxListTile(
                      value: _selfContained,
                      selected: _selfContained,
                      title: Text(
                          "Check this box if the rooms are self contained."),
                      onChanged: (v) {
                        setState(() {
                          _selfContained = v;
                        });
                      },
                    ),
                    CustomDivider(),
                    SizedBox(
                      height: 10,
                    ),
                    if (_selfContained)
                      StatisticText(
                        title: "How many bathrooms?",
                      ),
                    if (_selfContained)
                      SizedBox(
                        height: 5,
                      ),
                    if (_selfContained)
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: bathroomController,
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    StatisticText(
                      title:
                          "Now that you've provided some details about this roomtype, tell us which room numbers fall under this type. ",
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: roomNumberController,
                            decoration: InputDecoration(
                              hintText: "Type in a room number",
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (roomNumberController.text.trim().isEmpty) {
                              CommunicationServices().showToast(
                                "Please type in a room number.",
                                Colors.red,
                              );
                            } else {
                              addARoomNumber();
                            }
                          },
                          child: Text(
                            "Add Room",
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                        height: 100,
                        child: PaginateFirestore(
                          isLive: true,
                          onEmpty: Center(
                            child: Text("No rooms yet"),
                          ),
                          itemBuilderType: PaginateBuilderType.listView,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, snapshot, index) {
                            Room room = Room.fromSnapshot(snapshot[index]);

                            return SingleRoom(
                              room: room,
                              onRemoveRoom: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CustomDialogBox(
                                      bodyText:
                                          "Do you really want to delete this room and all its information? It will be difficult to un-do this.\n\nIf you want to change the room number or the room type or any other details, just tap on the edit button. No need to delete.",
                                      buttonText: "Delete The Room",
                                      onButtonTap: () {
                                        FirebaseFirestore.instance
                                            .collection(Room.DIRECTORY)
                                            .doc(snapshot[index].id)
                                            .delete();

                                        CommunicationServices().showToast(
                                          "Your room was deleted",
                                          Colors.green,
                                        );
                                      },
                                      showOtherButton: true,
                                    );
                                  },
                                );
                              },
                              onEditRoom: () {
                                UIServices().showDatSheet(
                                  RoomDetailsBottomSheet(
                                    roomID: room.id,
                                    propertyID: widget.propertyID,
                                  ),
                                  true,
                                  context,
                                );
                              },
                              roomID: room.id,
                              horizontal: false,
                            );
                          },
                          query: FirebaseFirestore.instance
                              .collection(Room.DIRECTORY)
                              .where(
                                Room.ROOMTYPE,
                                isEqualTo: randomID,
                              ),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    StatisticText(
                      title: "How many guests can each room take?",
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: guestCountController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    StatisticText(
                      title: "Price of these room types in UGX",
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    StatisticText(
                      title: "This is the price per",
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 100,
                      child: Row(
                        children: [
                          Expanded(
                            child: RowSelector(
                              onTap: () {
                                setState(() {
                                  frequency = PERNIGHT;
                                });
                              },
                              text: "Per Night",
                              selected: frequency == PERNIGHT,
                            ),
                          ),
                          Expanded(
                            child: RowSelector(
                              onTap: () {
                                setState(() {
                                  frequency = PERWEEK;
                                });
                              },
                              text: "Per Week",
                              selected: frequency == PERWEEK,
                            ),
                          ),
                          Expanded(
                            child: RowSelector(
                              onTap: () {
                                setState(() {
                                  frequency = PERMONTH;
                                });
                              },
                              text: "Per Month",
                              selected: frequency == PERMONTH,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: Row(
                        children: [
                          Expanded(
                            child: RowSelector(
                              onTap: () {
                                setState(() {
                                  frequency = PERSEMISTER;
                                });
                              },
                              text: "Per Semister",
                              selected: frequency == PERSEMISTER,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    )
                  ],
                ),
              ),
            ),
          ),
          ProceedButton(
            processing: processing,
            onTap: () {
              if (nameController.text.trim().isEmpty) {
                CommunicationServices().showToast(
                  "Please provide a name for this room type.",
                  Colors.red,
                );
              } else {
                if (guestCountController.text.trim().isEmpty) {
                  CommunicationServices().showToast(
                    "The total number of guest slots is less than 1.",
                    Colors.red,
                  );
                } else {
                  if (bathroomController.text.trim().isEmpty &&
                      _selfContained) {
                    CommunicationServices().showToast(
                      "The total number of bathrooms is less than 0 and yet you said the place is self contained.",
                      Colors.red,
                    );
                  } else {
                    if (priceController.text.trim().isEmpty) {
                      CommunicationServices().showToast(
                        "Please provide the price of these rooms.",
                        Colors.red,
                      );
                    } else {
                      uploadRoomType();
                    }
                  }
                }
              }
            },
            text: "Proceed",
          )
        ],
      ),
    );
  }

  addARoomNumber() {
    FirebaseFirestore.instance.collection(Room.DIRECTORY).add({
      Room.ROOMNUMBER: roomNumberController.text.trim(),
      Room.PROPERTY: widget.propertyID,
      Room.ROOMTYPE: randomID,
      Room.DATEOFADDING: DateTime.now().millisecondsSinceEpoch,
    });
  }

  uploadRoomType() {
    setState(() {
      processing = true;
    });

    FirebaseFirestore.instance
        .collection(RoomType.DIRECTORY)
        .doc(randomID)
        .set({
      RoomType.BATHROOMS: int.parse(bathroomController.text.trim()),
      RoomType.DESCRIPTION: descriptionController.text.trim(),
      RoomType.NAME: nameController.text.trim(),
      RoomType.SELFCONTAINED: _selfContained,
      RoomType.PRICE: int.parse(priceController.text.trim()),
      RoomType.PAYMENTFREQUENCY: frequency,
      RoomType.PROPERTY: widget.propertyID,
      RoomType.TOTALGUESTCOUNT: int.parse(guestCountController.text.trim()),
    }).then((value) {
      Navigator.of(context).pop();

      CommunicationServices().showToast(
        "The rooms was successfully updated",
        Colors.green,
      );
    });
  }
}
