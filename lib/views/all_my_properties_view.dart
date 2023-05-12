import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/views/dashboard.dart';
import 'package:dorx/views/first_view.dart';
import 'package:dorx/views/no_property_view.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AllMyPropertiesView extends StatefulWidget {
  const AllMyPropertiesView({Key key}) : super(key: key);

  @override
  State<AllMyPropertiesView> createState() => _AllMyPropertiesViewState();
}

class _AllMyPropertiesViewState extends State<AllMyPropertiesView> {
  DateTime currentBackPressTime;
  Box box;

  @override
  void initState() {
    box = Hive.box(DorxSettings.DORXBOXNAME);
    super.initState();
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;

      CommunicationServices().showSnackBar(
        "Press back once more to exit $capitalizedAppName",
        context,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: onWillPop,
        child: OnlyWhenLoggedIn(
          loadingView: LoadingWidget(),
          notSignedIn: FirstView(),
          signedInBuilder: (uid) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(Property.DIRECTORY)
                  .where(
                    Property.OWNERS,
                    arrayContains: uid,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return LoadingWidget();
                } else {
                  if (snapshot.data.docs.isEmpty) {
                    return NoPropertyView();
                  } else {
                    if (snapshot.data.docs.length == 1) {
                      Property property =
                          Property.fromSnapshot(snapshot.data.docs[0]);

                      if (property.accessible) {
                        if (Provider.of<PropertyManagement>(
                              context,
                              listen: false,
                            ).getCurrentPropertyID() ==
                            null) {
                          Provider.of<PropertyManagement>(
                            context,
                            listen: false,
                          ).editPropertyID(
                            property.id,
                            false,
                          );

                          Provider.of<PropertyManagement>(
                            context,
                            listen: false,
                          ).editPropertyModel(
                            property,
                            false,
                          );
                        }

                        box.put(
                          UserModel.ACCOUNTTYPES,
                          property.ownersMap[uid] ?? ThingType.RECEPTIONIST,
                        );

                        DorxSettings settings = DorxSettings.fromMap(
                          property.settingsMap,
                          null,
                        );

                        box.put(
                          DorxSettings.SETTINGSMAP,
                          getSettingsMap(settings),
                        );

                        return Dashboard();
                      } else {
                        return bodyWithManyProperties(
                          [property],
                          uid,
                        );
                      }
                    } else {
                      List<Property> pp = [];

                      snapshot.data.docs.forEach((e) {
                        pp.add(Property.fromSnapshot(e));
                      });

                      return bodyWithManyProperties(
                        pp,
                        uid,
                      );
                    }
                  }
                }
              },
            );
          },
        ),
      ),
    );
  }

  bodyWithManyProperties(
    List<Property> properties,
    String uid,
  ) {
    return SafeArea(
      child: Column(
        children: [
          BackBar(
            showIcon: false,
            icon: null,
            onPressed: null,
            text: "Select A Property",
          ),
          TransparentButton(
            onTap: () {
              StorageServices().launchTheThing(
                "tel:$dorxPhoneNumber",
              );
            },
            text: "Add New Property",
            icon: Icon(Icons.add),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: properties.map<Widget>((property) {
                  return SingleProperty(
                    propertyID: property.id,
                    property: property,
                    selectable: true,
                    onTap: () async {
                      Provider.of<PropertyManagement>(
                        context,
                        listen: false,
                      ).editPropertyID(
                        property.id,
                        true,
                      );

                      Provider.of<PropertyManagement>(
                        context,
                        listen: false,
                      ).editPropertyModel(
                        property,
                        true,
                      );

                      DorxSettings settings = DorxSettings.fromMap(
                        property.settingsMap,
                        null,
                      );

                      box.put(
                        DorxSettings.SETTINGSMAP,
                        getSettingsMap(settings),
                      );

                      box.put(
                        UserModel.ACCOUNTTYPES,
                        property.ownersMap[uid] ?? ThingType.RECEPTIONIST,
                      );

                      context.pushNamed(
                        RouteConstants.home,
                      );
                    },
                    selected: Provider.of<PropertyManagement>(context,
                                    listen: true)
                                .getCurrentPropertyID() !=
                            null &&
                        Provider.of<PropertyManagement>(context, listen: true)
                                .getCurrentPropertyID() ==
                            property.id,
                  );
                }).followedBy([
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ShamelessSelfPlug(),
                  ),
                  CustomDivider(),
                  ListTile(
                    title: Text(
                      "Log out",
                      textAlign: TextAlign.center,
                    ),
                    onTap: () async {
                      await AuthProvider.of(context).auth.signOut();

                      Provider.of<PropertyManagement>(context, listen: false)
                          .clear();

                      Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      );
                    },
                  ),
                  CustomDivider(),
                  SizedBox(
                    height: 20,
                  )
                ]).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
