import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/services/services.dart';
import 'package:dorx/widgets/custom_divider.dart';
import 'package:dorx/widgets/custom_switch.dart';
import 'package:dorx/widgets/dashboard_item.dart';
import 'package:dorx/widgets/loading_widget.dart';
import 'package:dorx/widgets/only_when_logged_in.dart';
import 'package:dorx/widgets/setup_real_estate_options.dart';
import 'package:dorx/widgets/top_back_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../main.dart';
import '../models/models.dart';
import '../theming/theme_controller.dart';

class SettingsBottomSheet extends StatefulWidget {
  const SettingsBottomSheet({Key key}) : super(key: key);

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
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
          text: "Settings",
          dontShowSettings: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Column(
            children: [
              CustomSwitch(
                text: "Change app to light / dark theme ",
                selected: ThemeBuilder.of(context).getCurrentTheme() ==
                    Brightness.light,
                onTap: (v) async {
                  setState(() {
                    if (v) {
                      ThemeBuilder.of(context).makeLight();

                      box.put(
                        sharedPrefBrightness,
                        "light",
                      );
                    } else {
                      ThemeBuilder.of(context).makeDark();

                      box.put(
                        sharedPrefBrightness,
                        "dark",
                      );
                    }
                  });
                },
                icon: Icons.sunny,
              ),
              PopupMenuButton(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.language),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          translation(context).changeLanguage,
                          style: darkTitle,
                        ),
                      )
                    ],
                  ),
                ),
                itemBuilder: (context) {
                  return Language.languageList()
                      .map(
                        (e) => PopupMenuItem(
                          value: e.languageCode,
                          child: Text(
                            "${e.name}  ${e.flag}",
                          ),
                        ),
                      )
                      .toList();
                },
                onSelected: (val) async {
                  Locale locale = await saveLocaleToPrefs(
                    val,
                    box,
                  );

                  MyApp.setLocale(context, locale);
                },
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
        Expanded(
          child: OnlyWhenLoggedIn(signedInBuilder: (uid) {
            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(UserModel.DIRECTORY)
                    .doc(uid)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return LoadingWidget();
                  } else {
                    UserModel userModel = UserModel.fromSnapshot(
                      snap.data,
                      Provider.of<PropertyManagement>(context)
                          .getCurrentPropertyID(),
                    );

                    return Consumer<PropertyManagement>(
                        builder: (context, rest, bb) {
                      if (rest.data.isEmpty) {
                        return body(null, userModel);
                      } else {
                        return StreamBuilder(
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return LoadingWidget();
                            } else {
                              Property property =
                                  Property.fromSnapshot(snapshot.data);

                              return body(property, userModel);
                            }
                          },
                          stream: FirebaseFirestore.instance
                              .collection(Property.DIRECTORY)
                              .doc(Provider.of<PropertyManagement>(context)
                                  .getCurrentPropertyID())
                              .snapshots(),
                        );
                      }
                    });
                  }
                });
          }),
        )
      ],
    );
  }

  Widget body(
    Property property,
    UserModel user,
  ) {
    DorxSettings settings = DorxSettings.fromMap(
      property?.settingsMap,
      user.settingsMAp,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (property != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatisticText(
                    title: "Property Settings",
                  ),
                  CustomSwitch(
                    text:
                        "This property is available for booking (show it to the customers)",
                    selected: property.available,
                    onTap: (v) {
                      FirebaseFirestore.instance
                          .collection(Property.DIRECTORY)
                          .doc(property.id)
                          .update({
                        Property.AVAILABLE: v,
                      });
                    },
                    icon: Icons.visibility,
                  ),
                  if (property.useAdvanced)
                    CustomSwitch(
                      text: "Enable room service requests",
                      selected: property.roomService,
                      onTap: (v) {
                        FirebaseFirestore.instance
                            .collection(Property.DIRECTORY)
                            .doc(property.id)
                            .update({
                          Property.ROOMSERVICE: v,
                        });
                      },
                      icon: Icons.trolley,
                    ),
                  CustomSwitch(
                    text: "Automatically approve bookings",
                    selected: settings.autoApproveBookings,
                    onTap: (v) {
                      dynamic dd = property.settingsMap ?? {};
                      dd.addAll({
                        DorxSettings.AUTOAPPROVEBOOKINGS: v,
                      });

                      FirebaseFirestore.instance
                          .collection(Property.DIRECTORY)
                          .doc(property.id)
                          .update({
                        DorxSettings.SETTINGSMAP: dd,
                      });
                    },
                    icon: Icons.safety_divider,
                  ),
                  if (property.useAdvanced)
                    CustomSwitch(
                      text:
                          "Automatically add numbers to your customer's names for easy searching.",
                      selected: settings.autoAddNumbers,
                      onTap: (v) {
                        dynamic dd = property.settingsMap ?? {};
                        dd.addAll({
                          DorxSettings.AUTOADDNUMBERS: v,
                        });

                        FirebaseFirestore.instance
                            .collection(Property.DIRECTORY)
                            .doc(property.id)
                            .update({
                          DorxSettings.SETTINGSMAP: dd,
                        });
                      },
                      icon: Icons.storage,
                    ),
                  CustomDivider(),
                  ListTile(
                    onTap: () {
                      UIServices().showDatSheet(
                        SetupPropertyRealEstateOptions(property: property),
                        true,
                        context,
                      );
                    },
                    title: Text(
                      "Edit my property listing",
                    ),
                  ),
                  CustomDivider(),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            StatisticText(
              title: "User Account Settings",
            ),
            CustomSwitch(
              text: "Email notifications",
              selected: settings.emailNotifications,
              onTap: (v) {
                dynamic dd = user.settingsMAp ?? {};
                dd.addAll({
                  DorxSettings.EMAILNOTIFICATIONS: v,
                });

                FirebaseFirestore.instance
                    .collection(UserModel.DIRECTORY)
                    .doc(user.id)
                    .update({
                  DorxSettings.SETTINGSMAP: dd,
                });
              },
              icon: Icons.email,
            ),
          ],
        ),
      ),
    );
  }
}
