import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/constants/constants.dart';
import 'package:dorx/models/models.dart';
import 'package:dorx/services/services.dart';
import 'package:dorx/widgets/add_new_room_type_bottom_sheet.dart';
import 'package:dorx/widgets/custom_dialog_box.dart';
import 'package:dorx/widgets/paginate_firestore.dart';
import 'package:dorx/widgets/single_big_button.dart';
import 'package:dorx/widgets/single_room_type.dart';
import 'package:dorx/widgets/top_back_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllRoomTypesView extends StatefulWidget {
  const AllRoomTypesView({Key key}) : super(key: key);

  @override
  State<AllRoomTypesView> createState() => _AllRoomTypesViewState();
}

class _AllRoomTypesViewState extends State<AllRoomTypesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackBar(
              icon: null,
              onPressed: null,
              text: "All Room types",
            ),
            Expanded(
              child: PaginateFirestore(
                isLive: true,
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
                    decoration: BoxDecoration(
                      borderRadius: standardBorderRadius,
                      border: Border.all(),
                    ),
                    padding: EdgeInsets.all(2),
                    margin: EdgeInsets.all(5),
                    child: Column(
                      children: [
                        SingleRoomType(
                          onRemoveRoomType: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return CustomDialogBox(
                                    bodyText:
                                        "Are you sure you want to delete this room type? This will also delete all rooms of this type and all attendance history will be lost.\n\nPlease be sure before proceeding. There is no Un-doing.",
                                    buttonText: "Delete it",
                                    onButtonTap: () {
                                      FirebaseFirestore.instance
                                          .collection(RoomType.DIRECTORY)
                                          .doc(roomType.id)
                                          .delete();

                                      CommunicationServices().showToast(
                                        "Successfully deleted it.",
                                        Colors.red,
                                      );
                                    },
                                    showOtherButton: true,
                                  );
                                });
                          },
                          onEditRoomType: () {
                            UIServices().showDatSheet(
                              AddNewRoomTypeBottomSheet(
                                roomType: roomType,
                                propertyID: Provider.of<PropertyManagement>(
                                        context,
                                        listen: false)
                                    .getCurrentPropertyID(),
                              ),
                              true,
                              context,
                            );
                          },
                          roomType: roomType,
                          roomTypeID: roomType.id,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: SingleBigButton(
                                color: primaryColor,
                                text: "View Rooms",
                                onPressed: () {
                                  context.pushNamed(
                                    RouteConstants.allRoomsInAType,
                                    params: {
                                      "id": roomType.id,
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          UIServices().showDatSheet(
            AddNewRoomTypeBottomSheet(
              roomType: null,
              propertyID: Provider.of<PropertyManagement>(
                context,
                listen: false,
              ).getCurrentPropertyID(),
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
