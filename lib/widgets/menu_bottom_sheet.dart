import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import 'widgets.dart';
import 'package:hive/hive.dart';

import '../models/models.dart';

class MenuBottomSheet extends StatefulWidget {
  MenuBottomSheet({Key key}) : super(key: key);

  @override
  State<MenuBottomSheet> createState() => _MenuBottomSheetState();
}

class _MenuBottomSheetState extends State<MenuBottomSheet> {
  String mode;
  Box box;

  @override
  void initState() {
    box = Hive.box(DorxSettings.DORXBOXNAME);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mode = box.get(UserModel.ACCOUNTTYPES);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    capitalizedAppName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mode == ThingType.PROPERTYMANAGER)
                          singleDrawerItem(
                            label: translation(context).property,
                            icon: Icon(
                              Icons.house,
                            ),
                            onTap: () {
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
                        if (mode == ThingType.PROPERTYMANAGER &&
                            Provider.of<PropertyManagement>(context)
                                .getCurrentPropertyModel()
                                .useAdvanced)
                          singleDrawerItem(
                            label: translation(context).attachedFoodPlaces,
                            icon: Icon(
                              Icons.food_bank,
                            ),
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.attachedFoodPlaces,
                              );
                            },
                          ),
                        if (mode == ThingType.PROPERTYMANAGER &&
                            Provider.of<PropertyManagement>(context)
                                .getCurrentPropertyModel()
                                .useAdvanced)
                          singleDrawerItem(
                            label: translation(context).noticeBoard,
                            icon: Icon(
                              FontAwesomeIcons.thumbtack,
                            ),
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.noticeboards,
                              );
                            },
                          ),
                        if (mode == ThingType.PROPERTYMANAGER &&
                            Provider.of<PropertyManagement>(context)
                                .getCurrentPropertyModel()
                                .useAdvanced)
                          singleDrawerItem(
                            label: "Bills and expenses",
                            icon: Icon(
                              FontAwesomeIcons.moneyBill,
                            ),
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.billsAndExpenses,
                              );
                            },
                          ),
                        singleDrawerItem(
                          label: translation(context).payments,
                          icon: Icon(Icons.monetization_on),
                          onTap: () {
                            context
                                .pushNamed(RouteConstants.allPayments, params: {
                              "id": Provider.of<PropertyManagement>(
                                context,
                                listen: false,
                              ).getCurrentPropertyID(),
                            }, queryParams: {
                              "type": ThingType.PROPERTY,
                            });
                          },
                        ),
                        if (Provider.of<PropertyManagement>(context)
                            .getCurrentPropertyModel()
                            .useAdvanced)
                          singleDrawerItem(
                            label: translation(context).myCustomers,
                            icon: Icon(
                              FontAwesomeIcons.user,
                            ),
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.allCustomers,
                              );
                            },
                          ),
                        if (mode == ThingType.PROPERTYMANAGER &&
                            Provider.of<PropertyManagement>(context)
                                .getCurrentPropertyModel()
                                .useAdvanced)
                          singleDrawerItem(
                            label: "Reminders",
                            icon: Icon(
                              Icons.alarm,
                            ),
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.reminders,
                              );
                            },
                          ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          translation(context).support,
                          style: TextStyle(fontSize: 17),
                        ),
                        if (mode == ThingType.PROPERTYMANAGER)
                          singleDrawerItem(
                            label: translation(context).settings,
                            icon: Icon(Icons.settings),
                            onTap: () {
                              UIServices().showDatSheet(
                                SettingsBottomSheet(),
                                true,
                                context,
                              );
                            },
                          ),
                        singleDrawerItem(
                          label: translation(context).feedback,
                          icon: Icon(Icons.feedback),
                          onTap: () {
                            FeedbackServices().startFeedingBackward(
                              context,
                              mode,
                            );
                          },
                        ),
                        singleDrawerItem(
                          label: translation(context).aboutUs,
                          onTap: () {
                            context.pushNamed(
                              RouteConstants.aboutUs,
                            );
                          },
                          icon: Icon(
                            Icons.help,
                          ),
                        ),
                        singleDrawerItem(
                          label: "Share $capitalizedAppName",
                          onTap: () {
                            //TODO: sharing

                            // Share.share(
                            //   'Hey there. I know we probably haven\'t texted in a while, but i just found a revolutionary app i think you\'d reeeally like.. Tap this link $realEstateManagerAppLinkToPlaystore',
                            //   subject: 'I found something you may like.',
                            // );
                          },
                          icon: Icon(
                            Icons.share,
                          ),
                        ),
                        singleDrawerItem(
                          label: "Rate $capitalizedAppName",
                          onTap: () {
                            StorageServices().launchTheThing(
                              realEstateManagerAppLinkToPlaystore,
                            );
                          },
                          icon: Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ShamelessSelfPlug(),
                  CustomSizedBox(
                    sbSize: SBSize.small,
                    height: true,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () async {
                  if (AuthProvider.of(context).auth.isSignedIn()) {
                    try {
                      await AuthProvider.of(context).auth.signOut();

                      Provider.of<PropertyManagement>(context, listen: false)
                          .clear();

                      Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      );
                    } catch (e) {
                      CommunicationServices().showToast(
                        "There was an error logging you out. ${e.toString()}",
                        Colors.blue,
                      );
                    }
                  } else {
                    UIServices().showLoginSheet(
                      AuthFormType.signIn,
                      (v) {},
                      context,
                    );
                  }
                },
                child: OnlyWhenLoggedIn(
                  notSignedIn: Text(
                    translation(context).signIn,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  signedInBuilder: (uid) {
                    return Text(
                      translation(context).logOut,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        )
      ],
    );
  }

  singleDrawerItem({
    @required String label,
    String image,
    @required Function onTap,
    @required Icon icon,
  }) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                image == null
                    ? icon
                    : CircleAvatar(
                        child: SingleImage(
                          image: image,
                        ),
                      ),
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: false,
                ),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
          Divider(
            height: 5,
          )
        ],
      ),
    );
  }
}
