import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:overlay_support/overlay_support.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import 'services.dart';

enum AuthFormType { signIn, signUp, reset }

class UIServices {
  SliverGridDelegate getSliverGridDelegate(
    BuildContext context,
  ) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: kIsWeb
          ? Responsive.isMobile(context)
              ? 2
              : 4
          : 2,
    );
  }

  showPopUpPushNotification(
    PushNotification notification,
    BuildContext context,
  ) {
    showSimpleNotification(
      Text(notification.title),
      leading: GestureDetector(
        onTap: () {
          StorageServices().handleClick(
            notification.thingType,
            notification.thingID,
            context,
          );
        },
        child: CircleAvatar(
          backgroundImage: notification.image == null
              ? AssetImage(logo)
              : NetworkImage(
                  notification.image,
                ),
        ),
      ),
      subtitle: GestureDetector(
        onTap: () {
          StorageServices().handleClick(
            notification.thingType,
            notification.thingID,
            context,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            notification.body,
          ),
        ),
      ),
      slideDismissDirection: DismissDirection.horizontal,
      background: primaryColor,
      duration: Duration(
        seconds: 10,
      ),
    );
  }

  Future<dynamic> showDatSheet(
    Widget sheet,
    bool willThisThingNeedScrolling,
    BuildContext context, {
    double height,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: willThisThingNeedScrolling,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: height ?? MediaQuery.of(context).size.height * 0.9,
            child: StatefulBuilder(builder: (context, setIt) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).canvasColor,
                      child: Icon(
                        Icons.close,
                      ),
                    ),
                  ),
                  CustomSizedBox(
                    sbSize: SBSize.smallest,
                    height: true,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          16,
                        ),
                        topRight: Radius.circular(
                          16,
                        ),
                      ),
                      child: Container(
                        color: Theme.of(context).canvasColor,
                        child: sheet,
                      ),
                    ),
                  )
                ],
              );
            }),
          ),
        );
      },
    );
  }

  ImageProvider<Object> getImageProvider(
    dynamic asset,
  ) {
    return asset == null
        ? null
        : asset is File
            ? FileImage(asset)
            : asset.toString().trim().contains(
                      "assets/images",
                    )
                ? AssetImage(
                    asset,
                  )
                : NetworkImage(
                    asset,
                  );
  }

  DecorationImage decorationImage(
    dynamic asset,
    bool darken,
  ) {
    return asset == null
        ? null
        : DecorationImage(
            image: asset is File
                ? FileImage(asset)
                : asset.toString().trim().contains(
                          "assets/images",
                        )
                    ? AssetImage(
                        asset,
                      )
                    : NetworkImage(
                        asset,
                      ),
            fit: BoxFit.cover,
            colorFilter: darken
                ? ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  )
                : null,
          );
  }

  showLoginSheet(
    AuthFormType initialAuthFormType,
    Function(String id) doAfterWards,
    BuildContext context,
  ) {
    showDatSheet(
      LoginSheet(
        initialAuthFormType: initialAuthFormType,
        doAfterWards: doAfterWards,
      ),
      true,
      context,
    );
  }
}

class LoginSheet extends StatefulWidget {
  final AuthFormType initialAuthFormType;
  final Function(String) doAfterWards;

  LoginSheet({
    Key key,
    @required this.initialAuthFormType,
    @required this.doAfterWards,
  }) : super(key: key);

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  AuthFormType authFormType;
  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool processing = false;
  Box box;
  final formKey = GlobalKey<FormState>();
  String _email, _password, _warning;
  bool visible = false;
  String _switchButton, _submitButtonText;
  bool _showForgotPassword = false;

  @override
  void initState() {
    authFormType = widget.initialAuthFormType;
    box = Hive.box(DorxSettings.DORXBOXNAME);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    if (authFormType == AuthFormType.signIn) {
      _switchButton = "";
      _submitButtonText = translation(context).signIn;
      _showForgotPassword = true;
    } else {
      _switchButton = translation(context).returnToSignIn;
      _showForgotPassword = false;
      _submitButtonText = translation(context).submit;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            BackBar(
              icon: null,
              onPressed: null,
              text: "",
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    authFormType == AuthFormType.signIn
                        ? translation(context).signIn
                        : translation(context).resetPassword,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    ".",
                    style: TextStyle(color: primaryColor, fontSize: 40),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 0.002 * screenheight,
            ),
            _warning != null
                ? Container(
                    color: Colors.red,
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            _warning,
                            maxLines: 5,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                _warning = null;
                              });
                            }
                          },
                        )
                      ],
                    ),
                  )
                : SizedBox(),
            SizedBox(
              height: 0.002 * screenheight,
            ),
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (authFormType != AuthFormType.reset)
                      SizedBox(height: 10),
                    TextFormField(
                      validator: EmailValidator.validate,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      textInputAction: authFormType == AuthFormType.reset
                          ? TextInputAction.send
                          : TextInputAction.next,
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          Icons.email,
                        ),
                        hintText: translation(context).email,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.grey,
                          width: 0,
                        )),
                        contentPadding: EdgeInsets.all(10),
                      ),
                      onSaved: (value) => _email = value.trim(),
                    ),
                    SizedBox(height: 10),
                    if (authFormType != AuthFormType.reset)
                      TextFormField(
                        controller: passwordController,
                        validator: PasswordValidator.validate,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              !visible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  visible = !visible;
                                });
                              }
                            },
                          ),
                          hintText: translation(context).password,
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 0)),
                          contentPadding: EdgeInsets.all(10),
                        ),
                        onSaved: (value) => _password = value.trim(),
                        obscureText: !visible,
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (processing) {
                            CommunicationServices().showSnackBar(
                                translation(context).justASecWaitYouCanCancel,
                                context,
                                behavior: SnackBarBehavior.floating,
                                buttonText: translation(context).cancel,
                                whatToDo: () {
                              if (mounted) {
                                setState(() {
                                  processing = false;
                                });
                              }
                            });
                          } else {
                            doIt();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: standardBorderRadius,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: processing
                              ? SpinKitWave(
                                  color: Colors.white,
                                  size: 25,
                                )
                              : Text(
                                  _submitButtonText,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ),
                    if (_showForgotPassword)
                      Container(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          child: Text(
                            translation(context).forgotPassword,
                            style: TextStyle(color: primaryColor),
                          ),
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                authFormType = AuthFormType.reset;
                              });
                            }
                          },
                        ),
                      ),
                    if (authFormType == AuthFormType.reset)
                      TextButton(
                        child: Text(
                          _switchButton,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: () {
                          if (authFormType == AuthFormType.reset) {
                            formKey.currentState.reset();
                            if (mounted) {
                              setState(() {
                                authFormType = AuthFormType.signIn;
                              });
                            }
                          } else {
                            formKey.currentState.reset();
                            if (mounted) {
                              setState(() {
                                authFormType = AuthFormType.signIn;
                              });
                            }
                          }
                        },
                      ),
                    SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 18,
                        ),
                      ),
                      onPressed: () {
                        StorageServices().launchTheThing(
                          "tel:$dorxPhoneNumber",
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  doIt() async {
    final form = formKey.currentState;
    form.save();
    if (form.validate()) {
      form.save();
      try {
        if (mounted) {
          setState(() {
            processing = true;
          });
        }
        final auth = AuthProvider.of(context).auth;

        if (authFormType == AuthFormType.signIn) {
          preSignIn();
        } else if (authFormType == AuthFormType.reset) {
          await auth.sendPasswordResetEmail(_email);

          _warning = translation(context).resetEmailSent;

          if (mounted) {
            setState(
              () {
                authFormType = AuthFormType.signIn;
              },
            );
          }
        }
      } catch (e) {
        processing = false;

        if (mounted) {
          setState(() {
            _warning = e.toString();
          });
        }
      }
    }
  }

  handleError(dynamic error) {
    processing = false;

    if (mounted) {
      setState(() {
        _warning = error.toString();
      });
    }
  }

  preSignIn() {
    String path;
    _email
        .split(RegExp(
      r"[.,@]",
    ))
        .forEach(
      (element) {
        if (path != null) {
          path = "$path/${element.trim().toLowerCase()}";
        } else {
          path = element.trim().toLowerCase();
        }
      },
    );

    FirebaseDatabase.instance
        .ref()
        .child(UserModel.ACCOUNTTYPES)
        .child(path)
        .once()
        .then(
      (value) async {
        if (value == null ||
            value.snapshot == null ||
            value.snapshot.value == null) {
          _warning = translation(context).accountDoesntExist;

          setState(() {
            processing = false;
          });
        } else {
          Map ll = value.snapshot.value as Map;

          bool realEstateMAnager = ll[ThingType.PROPERTYMANAGER] != null;
          bool receptionist = ll[ThingType.RECEPTIONIST] != null;

          if (receptionist || realEstateMAnager) {
            signIn(
              realEstateMAnager
                  ? ThingType.PROPERTYMANAGER
                  : ThingType.RECEPTIONIST,
            );
          } else {
            handleError(translation(context).notPermittedToAccessApp);
          }
        }
      },
    );
  }

  signIn(String accountType) async {
    await AuthProvider.of(context)
        .auth
        .signInWithEmailAndPassword(_email, _password)
        .then((value) async {
      box.put(
        UserModel.ACCOUNTTYPES,
        accountType,
      );

      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        CommunicationServices().showToast(
          translation(context).giveUsNotificationPermissions,
          Colors.red,
        );
      }

      Navigator.of(context).pop();

      CommunicationServices().showToast(
        translation(context).successfullySignedIn,
        primaryColor,
      );

      widget.doAfterWards(value);
    }).timeout(
      Duration(
        seconds: 10,
      ),
      onTimeout: () {
        handleError(
          translation(context).errorLogginIn,
        );
      },
    ).catchError(
      (v) {
        handleError(
          v.toString(),
        );
      },
    );
  }
}

class MySliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  MySliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(MySliverAppBarDelegate oldDelegate) {
    return false;
  }
}
