import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class PropertyManagerView extends StatefulWidget {
  PropertyManagerView({Key key}) : super(key: key);

  @override
  State<PropertyManagerView> createState() => _PropertyManagerViewState();
}

class _PropertyManagerViewState extends State<PropertyManagerView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            AuthProvider.of(context).auth.getCurrentUser() == null ||
                    AuthProvider.of(context)
                            .auth
                            .getCurrentUser()
                            .displayName ==
                        null
                ? "Hello there 😃"
                : "Hi ${AuthProvider.of(context).auth.getCurrentUser().displayName} 😃",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          StatisticText(
            title: "Your tenants and bookings",
          ),
          SizedBox(
            height: 5,
          ),
          SingleBigButton(
            text: "New walk-in tenant",
            color: primaryColor,
            onPressed: () {},
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 150,
            child: PaginateFirestore(
              onEmpty: Center(
                child: Text(
                  "No bookings yet",
                ),
              ),
              itemBuilderType: PaginateBuilderType.listView,
              isLive: true,
              itemBuilder: (context, snapshot, index) {
                RoomServiceRequest roomServiceRequest =
                    RoomServiceRequest.fromSnapshot(snapshot[index]);

                return Text(roomServiceRequest.id);
              },
              query: FirebaseFirestore.instance
                  .collection(RoomServiceRequest.DIRECTORY)
                  .where(
                    RoomServiceRequest.PROPERTY,
                    isEqualTo: Provider.of<PropertyManagement>(context)
                        .getCurrentPropertyID(),
                  )
                  .where(
                    RoomServiceRequest.PENDING,
                    isEqualTo: true,
                  )
                  .orderBy(
                    RoomServiceRequest.DATE,
                    descending: true,
                  ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            child: SizedBox(
              height: 100,
              child: Row(
                children: {
                  "View Rooms": {
                    "icon": FontAwesomeIcons.restroom,
                    "onTap": () {
                      context.pushNamed(
                        RouteConstants.allRooms,
                      );
                    },
                  },
                  "View Room Types": {
                    "icon": FontAwesomeIcons.houseLaptop,
                    "onTap": () {
                      context.pushNamed(
                        RouteConstants.allRoomTypes,
                      );
                    },
                  }
                }
                    .entries
                    .map(
                      (e) => singleGradientCard(e),
                    )
                    .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            child: SizedBox(
              height: 100,
              child: Row(
                children: {
                  "Bills and Expenses Tracker": {
                    "icon": FontAwesomeIcons.moneyBill,
                    "onTap": () {
                      context.pushNamed(
                        RouteConstants.billsAndExpenses,
                      );
                    }
                  },
                }
                    .entries
                    .map(
                      (e) => singleGradientCard(e),
                    )
                    .toList(),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          StatisticText(
            title: "Room Service Requests",
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 150,
            child: PaginateFirestore(
              onEmpty: Center(
                child: Text(
                  "No room service requests yet",
                ),
              ),
              itemBuilderType: PaginateBuilderType.listView,
              isLive: true,
              itemBuilder: (context, snapshot, index) {
                RoomServiceRequest roomServiceRequest =
                    RoomServiceRequest.fromSnapshot(snapshot[index]);

                return Text(roomServiceRequest.id);
              },
              query: FirebaseFirestore.instance
                  .collection(RoomServiceRequest.DIRECTORY)
                  .where(
                    RoomServiceRequest.PROPERTY,
                    isEqualTo: Provider.of<PropertyManagement>(context)
                        .getCurrentPropertyID(),
                  )
                  .where(
                    RoomServiceRequest.PENDING,
                    isEqualTo: true,
                  )
                  .orderBy(
                    RoomServiceRequest.DATE,
                    descending: true,
                  ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          StatisticText(
            title: translation(context).yourProperty,
          ),
          Provider.of<PropertyManagement>(context).getCurrentPropertyID() ==
                  null
              ? Text(
                  "No Currently Selected Property",
                )
              : SingleProperty(
                  propertyID: Provider.of<PropertyManagement>(context)
                      .getCurrentPropertyID(),
                  property: null,
                  selectable: false,
                  selected: false,
                  onTap: null,
                ),
          if (Provider.of<PropertyManagement>(context).getCurrentPropertyID() !=
              null)
            SingleBigButton(
              text: "Edit your property",
              color: Colors.green,
              onPressed: () {
                FirebaseFirestore.instance
                    .collection(Property.DIRECTORY)
                    .doc(Provider.of<PropertyManagement>(
                      context,
                      listen: false,
                    ).getCurrentPropertyID())
                    .get()
                    .then(
                  (value) {
                    Property property = Property.fromSnapshot(
                      value,
                    );

                    UIServices().showDatSheet(
                      SetupPropertyRealEstateOptions(
                        property: property,
                      ),
                      true,
                      context,
                    );
                  },
                );
              },
            ),
          SingleBigButton(
            text: "View My Property (as the clients see it)",
            color: primaryColor,
            onPressed: () {
              context.pushNamed(
                RouteConstants.property,
                params: {
                  "id": Provider.of<PropertyManagement>(
                    context,
                    listen: false,
                  ).getCurrentPropertyID(),
                },
              );
            },
          ),
          SizedBox(
            height: 80,
          ),
        ]),
      ),
    );
  }

  Widget singleGradientCard(MapEntry e) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          e.value["onTap"]();
        },
        child: Container(
          height: double.infinity,
          margin: EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 2,
          ),
          padding: EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: standardBorderRadius,
            border: Border.all(
              color: primaryColor,
            ),
          ),
          child: Center(
            child: Row(
              children: [
                Icon(
                  e.value["icon"],
                  color: primaryColor,
                ),
                SizedBox(
                  width: 4,
                ),
                Expanded(
                  child: Text(
                    e.key,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons.chevron_right,
                  color: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
