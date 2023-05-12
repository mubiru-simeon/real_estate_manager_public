import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/constants/basic.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'package:provider/provider.dart';

import 'widgets.dart';

class AvailableShops extends StatefulWidget {
  const AvailableShops({Key key}) : super(key: key);

  @override
  State<AvailableShops> createState() => _AvailableShopsState();
}

class _AvailableShopsState extends State<AvailableShops> {
  Box box;

  @override
  void initState() {
    box = Hive.box(DorxSettings.DORXBOXNAME);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Your Properties",
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
          child: PaginateFirestore(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            footer: SliverList(
                delegate: SliverChildListDelegate([
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
            ])),
            itemBuilder: (
              context,
              snapshot,
              index,
            ) {
              Property property = Property.fromSnapshot(
                snapshot[index],
              );

              return SingleProperty(
                propertyID: property.id,
                property: property,
                selectable: true,
                onTap: () async {
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
                    property.ownersMap[
                            AuthProvider.of(context).auth.getCurrentUID()] ??
                        ThingType.RECEPTIONIST,
                  );

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
                },
                selected: Provider.of<PropertyManagement>(context, listen: true)
                            .getCurrentPropertyID() !=
                        null &&
                    Provider.of<PropertyManagement>(context, listen: true)
                            .getCurrentPropertyID() ==
                        property.id,
              );
            },
            query: FirebaseFirestore.instance
                .collection(Property.DIRECTORY)
                .where(
                  Property.OWNERS,
                  arrayContains: AuthProvider.of(context).auth.getCurrentUID(),
                ),
            isLive: true,
            itemBuilderType: PaginateBuilderType.listView,
          ),
        ),
      ],
    );
  }
}
