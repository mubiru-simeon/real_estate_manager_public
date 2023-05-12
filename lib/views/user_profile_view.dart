import 'package:hive/hive.dart';
import 'package:dorx/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class UserProfileView extends StatefulWidget {
  final UserModel user;
  final String uid;
  UserProfileView({
    Key key,
    @required this.user,
    @required this.uid,
  }) : super(key: key);

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView>
    with TickerProviderStateMixin {
  String mode;
  bool editLoading = false;
  TabController tabController;
  Box box;
  List modes = [
    "details",
    "food history",
    "payment history",
  ];

  @override
  void initState() {
    super.initState();
    box = Hive.box(DorxSettings.DORXBOXNAME);

    tabController = TabController(
      vsync: this,
      length: modes.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(UserModel.DIRECTORY)
            .doc(widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoadingWidget();
          } else {
            UserModel model = UserModel.fromSnapshot(
              snapshot.data,
              Provider.of<PropertyManagement>(context).getCurrentPropertyID(),
            );

            return body(model);
          }
        },
      ),
    );
  }

  body(UserModel userModel) {
    mode = box.get(UserModel.ACCOUNTTYPES);

    return Scaffold(
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (hj, jh) {
              return [
                CustomSliverAppBar(
                  title: "User Details",
                ),
                SliverPersistentHeader(
                  delegate: MySliverAppBarDelegate(
                    TabBar(
                      isScrollable: true,
                      controller: tabController,
                      labelColor: getTabColor(context, true),
                      unselectedLabelColor: getTabColor(context, false),
                      tabs: modes
                          .map(
                            (e) => Tab(
                              text: e.toString().toUpperCase(),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                )
              ];
            },
            body: TabBarView(
              controller: tabController,
              children: [
                CustomerDetails(
                  userModel: userModel,
                  mode: mode,
                ),
                CustomerOrderHistory(
                  uid: userModel.id,
                ),
                CustomerPaymentHistory(
                  uid: userModel.id,
                ),
              ],
            ),
          ),
          if (mode == ThingType.PROPERTYMANAGER || mode == ThingType.ADMIN)
            Positioned(
              bottom: 10,
              right: 10,
              child: Row(
                children: [
                  FloatingActionButton(
                    heroTag: "edit_user",
                    child: editLoading
                        ? LoadingWidget(
                            color: Colors.white,
                          )
                        : Icon(Icons.edit),
                    onPressed: () async {
                      if (userModel.email == null ||
                          userModel.email.trim().isEmpty) {
                        proceedToEditUser(
                          userModel,
                          true,
                        );
                      } else {
                        setState(() {
                          editLoading = true;
                        });

                        await StorageServices()
                            .checkIfEmailInUse(userModel.email)
                            .then((value) {
                          setState(() {
                            editLoading = false;
                          });

                          if (value == true) {
                            proceedToEditUser(
                              userModel,
                              false,
                            );
                          } else {
                            proceedToEditUser(
                              userModel,
                              true,
                            );
                          }
                        });
                      }
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  FloatingActionButton(
                    heroTag: "delete_user",
                    child: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CustomDialogBox(
                            bodyText:
                                "You're about to remove this user from your customers. Are you sure about this?",
                            buttonText: "Do it",
                            onButtonTap: () {
                              List pp = [];
                              for (var element in userModel.affiliations) {
                                pp.add(element);
                              }

                              pp.remove(Provider.of<PropertyManagement>(
                                context,
                                listen: false,
                              ).getCurrentPropertyID());

                              FirebaseFirestore.instance
                                  .collection(UserModel.DIRECTORY)
                                  .doc(userModel.id)
                                  .update({
                                UserModel.AFFILIATION: pp,
                              });

                              Navigator.of(context).pop();
                            },
                            showOtherButton: true,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  proceedToEditUser(
    UserModel userModel,
    bool showEmail,
  ) {
    if (AuthProvider.of(context).auth.isSignedIn() &&
        AuthProvider.of(context).auth.getCurrentUID() != widget.uid) {
      context.pushNamed(
        RouteConstants.editUser,
        extra: userModel,
        queryParams: {
          "showEmail": showEmail.toString(),
        },
      );
    } else {
      CommunicationServices().showToast(
        "To edit your user account, please use the client app.",
        Colors.red,
      );
    }
  }
}

class CustomerDetails extends StatefulWidget {
  final UserModel userModel;
  final String mode;
  const CustomerDetails({
    Key key,
    @required this.userModel,
    @required this.mode,
  }) : super(key: key);

  @override
  State<CustomerDetails> createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails>
    with AutomaticKeepAliveClientMixin {
  String mode;
  Box box;

  @override
  void initState() {
    box = Hive.box(DorxSettings.DORXBOXNAME);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final sorted = Map.fromEntries(
      widget.userModel.permissionUpdates.entries.toList()
        ..sort(
          (e1, e2) => e1.key.compareTo(e2.key),
        ),
    );

    mode = box.get(UserModel.ACCOUNTTYPES);

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              widget.userModel.profilePic != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        widget.userModel.profilePic,
                        width: kIsWeb
                            ? 100
                            : MediaQuery.of(context).size.width * 0.5,
                        height: kIsWeb
                            ? 100
                            : MediaQuery.of(context).size.width * 0.5,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, v, b) {
                          if (b == null) return v;

                          return Image(
                            width: kIsWeb
                                ? 100
                                : MediaQuery.of(context).size.width * 0.5,
                            height: kIsWeb
                                ? 100
                                : MediaQuery.of(context).size.width * 0.5,
                            image: UIServices().getImageProvider(
                              defaultUserPic,
                            ),
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image(
                        width: kIsWeb
                            ? 100
                            : MediaQuery.of(context).size.width * 0.5,
                        height: kIsWeb
                            ? 100
                            : MediaQuery.of(context).size.width * 0.5,
                        image: AssetImage(defaultUserPic),
                        fit: BoxFit.cover,
                      ),
                    ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Material(
              elevation: standardElevation,
              borderRadius: standardBorderRadius,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(children: [
                  titleAndSub(
                    context,
                    title: "Username",
                    sub: widget.userModel.userName,
                    showSpace: true,
                    visible: widget.userModel.userName != null,
                  ),
                  if (widget.userModel.email != null)
                    GestureDetector(
                      onTap: () {
                        StorageServices().launchTheThing(
                          "mailto:${widget.userModel.email}?subject=Your account on $capitalizedAppName&body=Hello.",
                        );
                      },
                      child: titleAndSub(
                        context,
                        title: "Email",
                        sub: widget.userModel.email,
                        showSpace: true,
                        clickable: true,
                        visible: widget.userModel.email != null,
                      ),
                    ),
                  if (widget.userModel.phoneNumber != null &&
                      widget.userModel.phoneNumber.trim().isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        StorageServices().launchTheThing(
                          "tel:${widget.userModel.phoneNumber}",
                        );
                      },
                      child: titleAndSub(
                        context,
                        title: "Phone Number (tap here to call)",
                        sub: widget.userModel.phoneNumber,
                        showSpace: true,
                        clickable: true,
                        visible: widget.userModel.phoneNumber != null,
                      ),
                    ),
                  if (widget.userModel.whatsappNumber != null &&
                      widget.userModel.whatsappNumber.trim().isNotEmpty)
                    GestureDetector(
                      onTap: () async {
                        StorageServices().launchTheThing(
                          "whatsapp://send?phone=${widget.userModel.whatsappNumber}&text=hello",
                        );
                      },
                      child: titleAndSub(
                        context,
                        title: "Whatsapp Number (Tap to chat)",
                        sub: widget.userModel.whatsappNumber,
                        showSpace: true,
                        clickable: true,
                        visible: widget.userModel.whatsappNumber != null,
                      ),
                    ),
                  titleAndSub(
                    context,
                    title: "Gender",
                    sub: widget.userModel.gender.toUpperCase(),
                    showSpace: true,
                    clickable: true,
                    visible: widget.userModel.gender != null,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (widget.userModel.referees.isNotEmpty)
                    Text(
                      "Referees",
                    ),
                  if (widget.userModel.referees.isNotEmpty)
                    Column(
                      children: widget.userModel.referees
                          .map(
                            (e) => Column(
                              children: [
                                CustomDivider(),
                                ListTile(
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (e[UserModel.EMAIL] != null)
                                        GestureDetector(
                                          onTap: () {
                                            StorageServices().launchTheThing(
                                              StorageServices().getEmailLink(
                                                e[UserModel.EMAIL],
                                                "Hello",
                                                "Hello",
                                              ),
                                            );
                                          },
                                          child: Text(
                                            e[UserModel.EMAIL].toString(),
                                            style: TextStyle(
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                      if (e[UserModel.PHONENUMBER] != null)
                                        GestureDetector(
                                          onTap: () {
                                            StorageServices().launchTheThing(
                                              "tel:${e[UserModel.PHONENUMBER]}",
                                            );
                                          },
                                          child: Text(
                                            e[UserModel.PHONENUMBER].toString(),
                                            style: TextStyle(
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    e[UserModel.USERNAME].toString(),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  CustomDivider(),
                  SizedBox(
                    height: 10,
                  ),
                  if (widget.userModel.adder != null) CustomDivider(),
                  if (widget.userModel.adder != null)
                    SizedBox(
                      height: 20,
                    ),
                  if (widget.userModel.adder != null)
                    Text(
                      "Created by:",
                      style: titleStyle,
                    ),
                  if (widget.userModel.adder != null)
                    SingleUser(
                      user: null,
                      userID: widget.userModel.adder,
                    ),
                  if (widget.userModel.permissionUpdates != null)
                    SizedBox(
                      height: 20,
                    ),
                  if (widget.userModel.permissionUpdates.isNotEmpty)
                    CustomDivider(),
                  if (widget.userModel.permissionUpdates.isNotEmpty)
                    SizedBox(
                      height: 20,
                    ),
                  if (widget.userModel.permissionUpdates.isNotEmpty)
                    Text(
                      "Permission Updates:",
                      style: titleStyle,
                    ),
                  if (widget.userModel.permissionUpdates.isNotEmpty)
                    Column(
                      children: sorted.entries
                          .map(
                            (e) => Container(
                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: standardBorderRadius,
                                border: Border.all(),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      DateService().datewithoutFirstWords(
                                        int.parse(e.key),
                                      ),
                                      style: titleStyle,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Mode: ${e.value["mode"]}",
                                        ),
                                        Text(
                                          e.value["type"]
                                              .toString()
                                              .toUpperCase(),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Done by",
                                        ),
                                        SingleUser(
                                            user: null,
                                            userID:
                                                e.value[UserModel.REGISTERER])
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList()
                          .reversed
                          .toList(),
                    )
                ]),
              ),
            ),
          )
        ],
      ),
    );
  }

  titleAndSub(
    BuildContext context, {
    String title,
    String sub,
    bool clickable,
    bool showSpace,
    bool visible,
  }) {
    return Visibility(
      visible: visible,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: TextStyle(
              fontSize: 17,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    sub,
                    style: TextStyle(
                      fontSize: 20,
                      color: clickable != null && clickable ? altColor : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: showSpace,
            child: SizedBox(
              height: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CustomerOrderHistory extends StatefulWidget {
  final String uid;
  const CustomerOrderHistory({
    Key key,
    @required this.uid,
  }) : super(key: key);

  @override
  State<CustomerOrderHistory> createState() => _CustomerOrderHistoryState();
}

class _CustomerOrderHistoryState extends State<CustomerOrderHistory>
    with AutomaticKeepAliveClientMixin {
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container();
  }

  @override
  bool get wantKeepAlive => true;
}

class CustomerPaymentHistory extends StatefulWidget {
  final String uid;

  const CustomerPaymentHistory({
    Key key,
    @required this.uid,
  }) : super(key: key);

  @override
  State<CustomerPaymentHistory> createState() => _CustomerPaymentHistoryState();
}

class _CustomerPaymentHistoryState extends State<CustomerPaymentHistory>
    with AutomaticKeepAliveClientMixin {
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container();
  }

  @override
  bool get wantKeepAlive => true;
}
