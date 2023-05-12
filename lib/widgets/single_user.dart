import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/models/models.dart';
import 'package:dorx/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dorx/constants/constants.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';

class SingleUser extends StatefulWidget {
  final String userID;
  final bool showBalance;
  final UserModel user;
  final bool showButton;
  final bool nullHeight;
  final bool selected;
  final bool horizontal;
  final Function onTap;
  const SingleUser({
    Key key,
    @required this.user,
    @required this.userID,
    this.showBalance = true,
    this.onTap,
    this.nullHeight = false,
    this.horizontal,
    this.showButton = false,
    this.selected = false,
  }) : super(key: key);

  @override
  State<SingleUser> createState() => _SingleUserState();
}

class _SingleUserState extends State<SingleUser> {
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

    return widget.user == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(UserModel.DIRECTORY)
                .doc(widget.userID)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.data() == null) {
                  return DeletedItem(
                    what: "User",
                    thingID: widget.userID,
                  );
                } else {
                  UserModel model = UserModel.fromSnapshot(
                    snapshot.data,
                    Provider.of<PropertyManagement>(
                      context,
                    ).getCurrentPropertyID(),
                  );

                  return balanceBuilder(
                    model,
                    context,
                  );
                }
              } else {
                return LoadingWidget();
              }
            })
        : balanceBuilder(
            widget.user,
            context,
          );
  }

  balanceBuilder(
    UserModel user,
    BuildContext context,
  ) {
    DorxSettings settings = DorxSettings.fromMap(
      box.get(DorxSettings.SETTINGSMAP),
      null,
    );

    return body(
      user,
      null,
      context,
      settings,
    );
  }

  body(
    UserModel user,
    dynamic balance,
    BuildContext context,
    DorxSettings settings, {
    bool showLoading = false,
  }) {
    return Container(
      margin: EdgeInsets.all(6),
      child: GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap();
          } else {
            if (canViewUSerProfilePage.contains(mode)) {
              context.pushNamed(
                RouteConstants.user,
                extra: user,
                params: {
                  "id": user.id,
                },
              );
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: standardBorderRadius,
          ),
          padding: EdgeInsets.all(3),
          child: Material(
            elevation: standardElevation,
            borderRadius: standardBorderRadius,
            child: ClipRRect(
              borderRadius: standardBorderRadius,
              child: Stack(
                children: [
                  SizedBox(
                    width: widget.horizontal != null && widget.horizontal
                        ? kIsWeb
                            ? 300
                            : MediaQuery.of(context).size.width * 0.7
                        : null,
                    height: widget.nullHeight
                        ? null
                        : MediaQuery.of(context).size.height * 0.2,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(9),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage:
                                          UIServices().getImageProvider(
                                        user.profilePic ?? defaultUserPic,
                                      ),
                                    ),
                                    CustomSizedBox(
                                      sbSize: SBSize.smallest,
                                      height: false,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.userName,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            user.email ??
                                                "This user has no email",
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (user.phoneNumber != null)
                                            Text(
                                              user.phoneNumber,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              if (widget.nullHeight) Spacer(),
                              if (balance != null)
                                Text(
                                  showLoading
                                      ? "Loading"
                                      : "Balance: ${TextService().putCommas(balance.toStringAsFixed(1))} UGX",
                                  style: titleStyle,
                                ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                        if (mode == ThingType.PROPERTYMANAGER &&
                            widget.showButton == true)
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Column(
                                children: [],
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                  if (widget.selected)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: SelectorThingie(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
