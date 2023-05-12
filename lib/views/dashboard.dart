import 'package:dorx/views/receptionist_view.dart';
import 'package:dorx/views/property_manager_view.dart';
import 'package:flutter/material.dart';
import 'package:dorx/models/models.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'bookings_view.dart';
import 'feedback_view.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String mode;
  Box box;
  bool sharing = false;
  String title = "Home";
  int _currentPage = 0;
  Map<IconData, Map<String, dynamic>> pages = {};
  PageController _controller;

  @override
  void initState() {
    super.initState();
    // initDynamicLinks();

    box = Hive.box(DorxSettings.DORXBOXNAME);
    PushNotificationService().registerNotification(context);
    PushNotificationService().checkForInitialMessage(context);
    PushNotificationService().onMessageAppListen(context);

    _controller = PageController(
      initialPage: _currentPage,
    );
  }

  // Future<void> initDynamicLinks() async {
  //   FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
  //     final Uri uri = dynamicLinkData.link;
  //     final queryParams = uri.queryParameters;

  //     print(uri.toString());

  //     print('--------------------- found a link ----------------------');
  //     if (queryParams.isNotEmpty) {
  //       context.pushNamed(
  //         dynamicLinkData.link.path,
  //         queryParams: queryParams,
  //       );
  //     } else {
  //       Navigator.pushNamed(
  //         context,
  //         dynamicLinkData.link.path,
  //       );
  //     }
  //   }).onError((error) {
  //     print('--------------------- error ----------------------');
  //     print(error.message);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    mode = box.get(UserModel.ACCOUNTTYPES);

    pages = {
      if (Provider.of<PropertyManagement>(context)
          .getCurrentPropertyModel()
          .useAdvanced)
        Icons.home: {
          "title": "Home",
          "page": mode == ThingType.RECEPTIONIST
              ? ReceptionistView()
              : PropertyManagerView()
        },
      FontAwesomeIcons.bed: {
        "page": BookingsView(),
        "title": "Bookings",
      },
      if (mode == ThingType.PROPERTYMANAGER)
        Icons.inbox: {
          "page": FeedbackView(),
          "title": "Feedback",
        },
      Icons.menu: {
        "page": Container(),
        "title": "Menu",
      },
    };

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            showLeading: false,
            title: title,
            showSearched: true,
          ),
          Expanded(
            child: Stack(
              children: [
                PageView(
                  onPageChanged: (v) {
                    setState(() {
                      _currentPage = v;
                    });
                  },
                  controller: _controller,
                  physics: NeverScrollableScrollPhysics(),
                  children: pages.values.map<Widget>((e) => e["page"]).toList(),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          FloatingActionButton(
                            heroTag: "share_property",
                            onPressed: () async {},
                            child: sharing
                                ? LoadingWidget(
                                    color: Colors.white,
                                  )
                                : Icon(Icons.share),
                          ),
                          if (mode == ThingType.RECEPTIONIST)
                            SizedBox(
                              width: 5,
                            ),
                          if (mode == ThingType.RECEPTIONIST)
                            FloatingActionButton(
                              heroTag: "feedback",
                              onPressed: () async {
                                FeedbackServices().startFeedingBackward(
                                  context,
                                  mode,
                                );
                              },
                              child: Icon(
                                Icons.inbox,
                              ),
                            ),
                          SizedBox(
                            width: 10,
                          ),
                          FloatingActionButton(
                            heroTag: "select_property",
                            onPressed: () async {
                              await UIServices().showDatSheet(
                                AvailableShops(),
                                true,
                                context,
                              );

                              setState(() {});
                            },
                            child: Icon(FontAwesomeIcons.hotel),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      NavBottomBar(
                          bottomRadius: 50,
                          bottomBarHeight: 60,
                          showBigButton: false,
                          bigIcon: Icons.add,
                          currentIndex: _currentPage,
                          buttonPosition: ButtonPosition.end,
                          children: pages.entries
                              .map(
                                (e) => NavIcon(
                                  icon: e.key,
                                  onTap: () {
                                    if (pages.keys.toList().indexOf(e.key) !=
                                        pages.length - 1) {
                                      title = e.value["title"];
                                    }

                                    selectTab(
                                      pages.keys.toList().indexOf(e.key),
                                    );
                                  },
                                ),
                              )
                              .toList()),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  selectTab(int index) async {
    if (index == pages.length - 1) {
      UIServices().showDatSheet(
        MenuBottomSheet(),
        true,
        context,
      );
    } else {
      _controller.jumpToPage(index);
    }
  }
}
