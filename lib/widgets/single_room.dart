import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/ui.dart';
import '../models/models.dart';
import 'deleted_item.dart';
import 'loading_widget.dart';

class SingleRoom extends StatefulWidget {
  final Room room;
  final String roomID;
  final Function onRemoveRoom;
  final bool putExpanded;
  final bool horizontal;
  final Function onEditRoom;
  SingleRoom({
    Key key,
    @required this.room,
    this.onRemoveRoom,
    this.onEditRoom,
    @required this.roomID,
    this.horizontal = false,
    this.putExpanded = false,
  }) : super(key: key);

  @override
  State<SingleRoom> createState() => _SingleRoomState();
}

class _SingleRoomState extends State<SingleRoom> {
  @override
  Widget build(BuildContext context) {
    return widget.room == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Room.DIRECTORY)
                .doc(widget.roomID)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.data() == null) {
                  return DeletedItem(
                    thingID: widget.roomID,
                    what: "Room",
                  );
                } else {
                  Room model = Room.fromSnapshot(snapshot.data);

                  return body(model);
                }
              } else {
                return LoadingWidget();
              }
            },
          )
        : body(widget.room);
  }

  body(Room room) {
    RoomAvailability rA = room.available(
      DateTime.now().millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
    );

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Stack(
        children: [
          Container(
            width: widget.horizontal
                ? MediaQuery.of(context).size.width * 0.4
                : double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: standardBorderRadius,
              border: Border.all(
                width: 1,
              ),
              color: getRoomColorFromAvailability(context, rA).withOpacity(0.5),
            ),
            padding: EdgeInsets.all(10),
            child: Text(
              room.roomNumber.toUpperCase(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            right: 5,
            bottom: 5,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    widget.onEditRoom();
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () {},
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
