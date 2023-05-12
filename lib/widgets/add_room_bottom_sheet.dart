import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/services/communications.dart';
import 'package:dorx/widgets/my_keyboard_listener_widget.dart';
import 'package:dorx/widgets/proceed_button.dart';
import 'package:dorx/widgets/top_back_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';

class AddARoomBottomSheet extends StatefulWidget {
  final Room room;
  final String roomTypeID;
  const AddARoomBottomSheet({
    Key key,
    @required this.room,
    @required this.roomTypeID,
  }) : super(key: key);

  @override
  State<AddARoomBottomSheet> createState() => _AddARoomBottomSheetState();
}

class _AddARoomBottomSheetState extends State<AddARoomBottomSheet> {
  TextEditingController nameController = TextEditingController();
  bool processing = false;

  @override
  void initState() {
    super.initState();

    if (widget.room != null) {
      nameController = TextEditingController(
        text: widget.room.roomNumber,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyKeyboardListenerWidget(
        proceed: proceed,
        child: Column(
          children: [
            BackBar(
              icon: null,
              onPressed: null,
              text: "Edit a room",
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Room Number",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ProceedButton(
              processing: processing,
              onTap: () {
                proceed();
              },
            ),
          ],
        ),
      ),
    );
  }

  proceed() {
    setState(() {
      processing = true;
    });
    
    if (widget.room == null) {
      FirebaseFirestore.instance.collection(Room.DIRECTORY).add({
        Room.ROOMNUMBER: nameController.text.trim(),
        Room.PROPERTY: Provider.of<PropertyManagement>(
          context,
          listen: false,
        ).getCurrentPropertyID(),
        Room.ROOMTYPE: widget.roomTypeID,
        Room.DATEOFADDING: DateTime.now().millisecondsSinceEpoch,
      }).then((value) {
        CommunicationServices().showToast(
          "Success",
          Colors.green,
        );

        Navigator.of(context).pop();
      });
    } else {
      FirebaseFirestore.instance
          .collection(Room.DIRECTORY)
          .doc(widget.room.id)
          .update({
        Room.ROOMNUMBER: nameController.text.trim(),
        Room.PROPERTY: Provider.of<PropertyManagement>(
          context,
          listen: false,
        ).getCurrentPropertyID(),
        Room.ROOMTYPE: widget.roomTypeID,
        Room.DATEOFADDING: DateTime.now().millisecondsSinceEpoch,
      }).then((value) {
        CommunicationServices().showToast(
          "Success",
          Colors.green,
        );

        Navigator.of(context).pop();
      });
    }
  }
}
