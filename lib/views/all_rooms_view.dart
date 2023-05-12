import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/constants/constants.dart';
import 'package:dorx/models/models.dart';
import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/widgets.dart';

class AllRoomsView extends StatefulWidget {
  const AllRoomsView({Key key}) : super(key: key);

  @override
  State<AllRoomsView> createState() => _AllRoomsViewState();
}

class _AllRoomsViewState extends State<AllRoomsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "My rooms",
          ),
          Expanded(
              child: PaginateFirestore(
            header: SliverList(
              delegate: SliverChildListDelegate([
                ColorCodeShower(
                  colors: roomColors.entries.map(
                    (e) => ColorCode.fromData(
                      e.value,
                      e.key == RoomAvailability.available
                          ? "Available"
                          : "Occupied",
                      null,
                    ),
                  ).toList(),
                ),
              ]),
            ),
            itemBuilderType: PaginateBuilderType.listView,
            query: FirebaseFirestore.instance
                .collection(RoomType.DIRECTORY)
                .where(
                  RoomType.PROPERTY,
                  isEqualTo: Provider.of<PropertyManagement>(context)
                      .getCurrentPropertyID(),
                )
                .orderBy(
                  RoomType.NAME,
                ),
            itemBuilder: (context, snapshot, index) {
              RoomType roomType = RoomType.fromSnapshot(snapshot[index]);

              return Container(
                padding: EdgeInsets.all(2),
                margin: EdgeInsets.only(
                  left: 5,
                  top: 5,
                  bottom: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: standardBorderRadius,
                ),
                child: Column(
                  children: [
                    SingleRoomType(
                      roomType: roomType,
                      simple: true,
                      roomTypeID: roomType.id,
                    ),
                    SizedBox(
                      height: 320,
                      child: PaginateFirestore(
                        header: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              AddButtonOnHeader(
                                onTap: () {
                                  UIServices().showDatSheet(
                                    AddARoomBottomSheet(
                                      room: null,
                                      roomTypeID: roomType.id,
                                    ),
                                    true,
                                    context,
                                  );
                                },
                                word: "Add some \n${roomType.name}",
                              )
                            ],
                          ),
                        ),
                        isLive: true,
                        query: FirebaseFirestore.instance
                            .collection(Room.DIRECTORY)
                            .where(
                              Room.ROOMTYPE,
                              isEqualTo: roomType.id,
                            )
                            .orderBy(
                              Room.ROOMNUMBER,
                            ),
                        itemBuilderType: PaginateBuilderType.gridView,
                        itemBuilder: (context, snapshot, index) {
                          Room room = Room.fromSnapshot(snapshot[index]);

                          return SingleRoom(
                            onRemoveRoom: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CustomDialogBox(
                                      bodyText:
                                          "Do you really want to delete this room and all its occupancy history?\n\n Be sure about this. There is no undoing this move.",
                                      buttonText: "Delete it",
                                      onButtonTap: () {
                                        FirebaseFirestore.instance
                                            .collection(Room.DIRECTORY)
                                            .doc(room.id)
                                            .delete();

                                        CommunicationServices().showToast(
                                          "Success",
                                          Colors.red,
                                        );
                                      },
                                      showOtherButton: true,
                                    );
                                  });
                            },
                            onEditRoom: () {
                              UIServices().showDatSheet(
                                AddARoomBottomSheet(
                                  roomTypeID: roomType.id,
                                  room: room,
                                ),
                                true,
                                context,
                              );
                            },
                            room: room,
                            roomID: room.id,
                          );
                        },
                        scrollDirection: Axis.horizontal,
                      ),
                    )
                  ],
                ),
              );
            },
          ))
        ]),
      ),
    );
  }
}
