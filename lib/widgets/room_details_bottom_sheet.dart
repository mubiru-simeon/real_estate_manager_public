import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'widgets.dart';

class RoomDetailsBottomSheet extends StatefulWidget {
  final String roomID;
  final String propertyID;
  RoomDetailsBottomSheet({
    Key key,
    @required this.roomID,
    @required this.propertyID,
  }) : super(key: key);

  @override
  State<RoomDetailsBottomSheet> createState() => _RoomDetailsBottomSheetState();
}

class _RoomDetailsBottomSheetState extends State<RoomDetailsBottomSheet>
    with TickerProviderStateMixin {
  TabController controller;
  List pages;

  @override
  void initState() {
    super.initState();
    pages = [
      "details",
      "occupants",
      "history",
    ];

    controller = TabController(vsync: this, length: pages.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (gh, hg) {
          return [
            SliverAppBar(
              pinned: true,
              title: Text(
                "Room Details",
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: MySliverAppBarDelegate(
                TabBar(
                  controller: controller,
                  labelColor: getTabColor(context, true),
                  unselectedLabelColor: getTabColor(context, false),
                  tabs: pages
                      .map(
                        (e) => Tab(
                          text: e.toString().toUpperCase(),
                        ),
                      )
                      .toList(),
                ),
              ),
            )
          ];
        },
        body: TabBarView(
          controller: controller,
          children: [
            RoomDetails(
              roomID: widget.roomID,
              propertyID: widget.propertyID,
            ),
            RoomOccupants(
              roomID: widget.roomID,
            ),
            RoomHistory(
              roomID: widget.roomID,
            ),
          ],
        ),
      ),
    );
  }
}

class RoomDetails extends StatefulWidget {
  final String roomID;
  final String propertyID;
  RoomDetails({
    Key key,
    @required this.roomID,
    @required this.propertyID,
  }) : super(key: key);

  @override
  State<RoomDetails> createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetails> {
  TextEditingController nameController = TextEditingController();
  String roomTypeID;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(Room.DIRECTORY)
          .doc(widget.roomID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingWidget();
        } else {
          Room room = Room.fromSnapshot(snapshot.data);
          roomTypeID = room.roomType;

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: 5,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Room Number",
                        ),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: room.roomNumber,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Room Type",
                        ),
                        StatefulBuilder(
                          builder: (BuildContext context, setIt) {
                            return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection(RoomType.DIRECTORY)
                                  .doc(roomTypeID)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return LoadingWidget();
                                } else {
                                  RoomType roomType =
                                      RoomType.fromSnapshot(snapshot.data);

                                  return Column(
                                    children: [
                                      CustomDivider(),
                                      ListTile(
                                        onTap: () async {
                                          String mat =
                                              await UIServices().showDatSheet(
                                            SelectARoomType(
                                              propertyID: widget.propertyID,
                                            ),
                                            true,
                                            context,
                                          );

                                          setIt(() {
                                            if (mat != null) {
                                              roomTypeID = mat;
                                            }
                                          });
                                        },
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                        ),
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              UIServices().getImageProvider(
                                            roomType.images.isEmpty
                                                ? bedroom
                                                : roomType.images[0],
                                          ),
                                        ),
                                        subtitle: Text(
                                          roomType.description.toString(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        title: Text(
                                          roomType.name.toUpperCase(),
                                        ),
                                      ),
                                      CustomDivider(),
                                    ],
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                ProceedButton(
                  text: "Update Room",
                  onTap: () {
                    FirebaseFirestore.instance
                        .collection(Room.DIRECTORY)
                        .doc(widget.roomID)
                        .update(
                      {
                        Room.ROOMNUMBER: nameController.text.trim(),
                        Room.ROOMTYPE: roomTypeID
                      },
                    ).then((value) {
                      CommunicationServices().showToast(
                        "Successfully updated your paper.",
                        Colors.green,
                      );
                    });
                  },
                )
              ],
            ),
          );
        }
      },
    );
  }
}

class SelectARoomType extends StatefulWidget {
  final String propertyID;
  SelectARoomType({
    Key key,
    @required this.propertyID,
  }) : super(key: key);

  @override
  State<SelectARoomType> createState() => _SelectARoomTypeState();
}

class _SelectARoomTypeState extends State<SelectARoomType> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Select A Room",
        ),
        Expanded(
          child: PaginateFirestore(
            itemBuilderType: PaginateBuilderType.listView,
            isLive: true,
            query:
                FirebaseFirestore.instance.collection(RoomType.DIRECTORY).where(
                      RoomType.PROPERTY,
                      isEqualTo: widget.propertyID,
                    ),
            itemBuilder: (context, snapshot, index) {
              RoomType roomType = RoomType.fromSnapshot(snapshot[index]);

              return SingleRoomType(
                roomType: roomType,
                roomTypeID: roomType.id,
              );
            },
          ),
        ),
        ProceedButton(
          text: "Finish",
          onTap: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}

class RoomOccupants extends StatefulWidget {
  final String roomID;
  RoomOccupants({
    Key key,
    @required this.roomID,
  }) : super(key: key);

  @override
  State<RoomOccupants> createState() => _RoomOccupantsState();
}

class _RoomOccupantsState extends State<RoomOccupants> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class RoomHistory extends StatefulWidget {
  final String roomID;
  RoomHistory({
    Key key,
    @required this.roomID,
  }) : super(key: key);

  @override
  State<RoomHistory> createState() => _RoomHistoryState();
}

class _RoomHistoryState extends State<RoomHistory> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
