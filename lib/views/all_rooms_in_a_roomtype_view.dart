import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';

class AllRoomsInARoomTypeView extends StatelessWidget {
  final String roomTypeID;
  const AllRoomsInARoomTypeView({
    Key key,
    @required this.roomTypeID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          BackBar(
            text: "Rooms in this room type",
            onPressed: null,
            icon: null,
          ),
          Expanded(
            child: PaginateFirestore(
              header: SliverList(
                delegate: SliverChildListDelegate([
                  ColorCodeShower(
                    colors: roomColors.entries
                        .map(
                          (e) => ColorCode.fromData(
                            e.value,
                            e.key == RoomAvailability.available
                                ? "Available"
                                : "Occupied",
                            null,
                          ),
                        )
                        .toList(),
                  ),
                ]),
              ),
              isLive: true,
              query: FirebaseFirestore.instance
                  .collection(Room.DIRECTORY)
                  .where(
                    Room.ROOMTYPE,
                    isEqualTo: roomTypeID,
                  )
                  .orderBy(
                    Room.ROOMNUMBER,
                  ),
              itemBuilderType: PaginateBuilderType.gridView,
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
                        roomTypeID: roomTypeID,
                        room: room,
                      ),
                      true,
                      context,
                    );
                  },
                  roomID: room.id,
                );
              },
            ),
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          UIServices().showDatSheet(
            AddARoomBottomSheet(
              room: null,
              roomTypeID: roomTypeID,
            ),
            true,
            context,
          );
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
