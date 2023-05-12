import 'dart:io';
import 'package:dorx/constants/constants.dart';
import 'package:dorx/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class EditProfileView extends StatefulWidget {
  final UserModel user;
  final bool showEmail;
  EditProfileView({
    Key key,
    @required this.user,
    @required this.showEmail,
  }) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  File img;
  List selectedImages = [];
  String initialPic;
  List<Map> referees = [];
  bool processing = false;
  TextEditingController userNameController;
  TextEditingController emailController;
  TextEditingController addressController;
  TextEditingController phoneNumberController;
  TextEditingController whatsappNumberController;

  @override
  void initState() {
    super.initState();
    setDefaults();
  }

  setDefaults() {
    initialPic = widget.user.entityUserData.profilePic;

    userNameController = TextEditingController(
      text: widget.user.entityUserData.userName,
    );

    whatsappNumberController = TextEditingController(
      text: widget.user.entityUserData.whatsappNumber,
    );

    addressController = TextEditingController(
      text: widget.user.entityUserData.address,
    );

    phoneNumberController = TextEditingController(
      text: widget.user.entityUserData.phoneNumber,
    );

    if (widget.showEmail) {
      emailController = TextEditingController(
        text: widget.user.entityUserData.email,
      );
    }

    for (var element in widget.user.entityUserData.images) {
      selectedImages.add(element);
    }

    for (var element in widget.user.entityUserData.referees) {
      referees.add(element);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.5),
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.9),
              Colors.black,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [
              0,
              0.4,
              0.8,
              0.9,
              1,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              BackBar(
                icon: null,
                onPressed: null,
                text: "Edit your profile",
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.blue,
                              ),
                              margin: EdgeInsets.only(right: 10),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: GestureDetector(
                                onTap: () {
                                  setDefaults();
                                  img = null;
                                  if (mounted) setState(() {});
                                },
                                child: Center(
                                  child: Text(
                                    "Reset All",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(vertical: 25),
                          child: Center(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: initialPic != null
                                      ? Image.network(
                                          widget.user.profilePic,
                                          width: kIsWeb
                                              ? 100
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                          height: kIsWeb
                                              ? 100
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, v, n) {
                                            if (n == null) return v;

                                            return Image(
                                              width: kIsWeb
                                                  ? 100
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                              height: kIsWeb
                                                  ? 100
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                              image: AssetImage(
                                                defaultUserPic,
                                              ),
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                      : Image(
                                          width: kIsWeb
                                              ? 100
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                          height: kIsWeb
                                              ? 100
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                          image: img == null
                                              ? AssetImage(
                                                  defaultUserPic,
                                                )
                                              : FileImage(img),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Visibility(
                                  visible: img != null,
                                  child: Positioned(
                                    top: 7,
                                    right: 7,
                                    child: IconButton(
                                      icon: CircleAvatar(
                                        child: Icon(
                                          Icons.close,
                                          size: 25,
                                        ),
                                      ),
                                      onPressed: () async {
                                        img = null;
                                        if (mounted) setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 7,
                                  right: 7,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.camera,
                                      size: 40,
                                    ),
                                    onPressed: () async {
                                      List temp =
                                          await ImageServices().pickImages(
                                        context,
                                        limit: 1,
                                      );

                                      initialPic = null;
                                      img = temp[0];
                                      if (mounted) setState(() {});
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: Material(
                            elevation: 10,
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  titleAndSub(
                                    title: "Username",
                                    type: TextInputType.text,
                                    controller: userNameController,
                                    hint: widget.user.userName,
                                    showSpace: true,
                                    visible: true,
                                  ),
                                  titleAndSub(
                                    title: "Phone Number",
                                    type: TextInputType.phone,
                                    controller: phoneNumberController,
                                    hint: widget.user.phoneNumber,
                                    showSpace: true,
                                    visible: true,
                                  ),
                                  titleAndSub(
                                    title: "Whatsapp Number",
                                    type: TextInputType.phone,
                                    controller: whatsappNumberController,
                                    hint: widget.user.whatsappNumber,
                                    showSpace: true,
                                    visible: true,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  if (widget.showEmail)
                                    titleAndSub(
                                      title: "Email",
                                      type: TextInputType.emailAddress,
                                      controller: emailController,
                                      hint: widget.user.email,
                                      showSpace: true,
                                      visible: true,
                                    ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  CustomDivider(),
                                  ListTile(
                                    leading: CircleAvatar(
                                      child: Icon(
                                        Icons.add,
                                      ),
                                    ),
                                    title: Text(
                                      translation(context).addAReferee,
                                    ),
                                    subtitle: Text(
                                      translation(context).aReferenceIsJust,
                                    ),
                                    onTap: () async {
                                      Map pp = await UIServices().showDatSheet(
                                        CustomerDetailsBottomSheet(
                                          title:
                                              translation(context).addAReferee,
                                        ),
                                        true,
                                        context,
                                      );

                                      if (pp != null && pp.isNotEmpty) {
                                        setState(() {
                                          referees.add(pp);
                                        });
                                      }
                                    },
                                  ),
                                  Column(
                                    children: referees
                                        .map(
                                          (e) => Column(
                                            children: [
                                              CustomDivider(),
                                              ListTile(
                                                trailing: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      referees.remove(e);
                                                    });
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 20,
                                                    child: Icon(
                                                      Icons.close,
                                                    ),
                                                  ),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (e[UserModel.EMAIL] !=
                                                        null)
                                                      GestureDetector(
                                                        onTap: () {
                                                          StorageServices()
                                                              .launchTheThing(
                                                            StorageServices()
                                                                .getEmailLink(
                                                              e[UserModel
                                                                  .EMAIL],
                                                              "Hello",
                                                              "Hello",
                                                            ),
                                                          );
                                                        },
                                                        child: Text(
                                                          e[UserModel.EMAIL]
                                                              .toString(),
                                                          style: TextStyle(
                                                            color: primaryColor,
                                                          ),
                                                        ),
                                                      ),
                                                    if (e[UserModel
                                                            .PHONENUMBER] !=
                                                        null)
                                                      GestureDetector(
                                                        onTap: () {
                                                          StorageServices()
                                                              .launchTheThing(
                                                                  "tel:${e[UserModel.PHONENUMBER]}");
                                                        },
                                                        child: Text(
                                                          e[UserModel
                                                                  .PHONENUMBER]
                                                              .toString(),
                                                          style: TextStyle(
                                                            color: primaryColor,
                                                          ),
                                                        ),
                                                      ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              SingleBigButton(
                                                            text: "Edit",
                                                            color: Colors.green,
                                                            onPressed:
                                                                () async {
                                                              Map pp =
                                                                  await UIServices()
                                                                      .showDatSheet(
                                                                CustomerDetailsBottomSheet(
                                                                  title:
                                                                      "Edit Personal Information",
                                                                ),
                                                                true,
                                                                context,
                                                              );

                                                              if (pp != null &&
                                                                  pp.isNotEmpty) {
                                                                setState(
                                                                  () {
                                                                    referees
                                                                        .remove(
                                                                            e);

                                                                    referees
                                                                        .add(
                                                                            pp);
                                                                  },
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child:
                                                              SingleBigButton(
                                                            text: "Remove",
                                                            color: Colors.red,
                                                            onPressed:
                                                                () async {
                                                              setState(
                                                                () {
                                                                  referees
                                                                      .remove(
                                                                          e);
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                title: Text(
                                                  e[UserModel.USERNAME]
                                                      .toString(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  CustomDivider(),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Wrap(
        children: [
          ProceedButton(
            text: "Update the Profile",
            onTap: () {
              if (userNameController.text.trim().isEmpty) {
                CommunicationServices().showToast(
                  "A name is needed. Please provide a UserName",
                  Colors.red,
                );
              } else {
                updateProfile();
              }
            },
            enablable: false,
            processing: processing,
          ),
        ],
      ),
    );
  }

  updateProfile() async {
    setState(() {
      processing = true;
    });

    if (widget.showEmail &&
        emailController.text.trim().isNotEmpty &&
        (emailController.text.trim() != widget.user.email)) {
      FirebaseFirestore.instance
          .collection(UserModel.DIRECTORY)
          .where(
            UserModel.EMAIL,
            isEqualTo: emailController.text.trim(),
          )
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          setState(() {
            processing = false;
          });

          UserModel userModel = UserModel.fromSnapshot(
            value.docs[0],
            Provider.of<PropertyManagement>(context, listen: false)
                .getCurrentPropertyID(),
          );

          showDD(
            userModel.id,
            userModel.userName,
          );
        } else {
          finish();
        }
      });
    } else {
      finish();
    }
  }

  showDD(
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CustomDialogBox(
          bodyText: null,
          buttonText: null,
          onButtonTap: null,
          showOtherButton: null,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "This person may already have an account. There's one named $name using this same email. Please confirm that it's him or not and add him to your customers, or contact us for complaint fixing.",
                  style: darkTitle,
                ),
                SizedBox(
                  height: 10,
                ),
                ProceedButton(
                  onTap: () {
                    context.pushNamed(
                      RouteConstants.user,
                      params: {
                        "id": id,
                      },
                    );
                  },
                  text: "View user",
                ),
                SizedBox(
                  height: 5,
                ),
                ProceedButton(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.red,
                  text: "Cancel and try a different email",
                ),
                SizedBox(
                  height: 5,
                ),
                ProceedButton(
                  onTap: () {
                    StorageServices().launchTheThing(
                      "tel:$dorxPhoneNumber",
                    );
                  },
                  color: Colors.blue,
                  text: "Contact us",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  finish() async {
    String uploadableProfPic;

    List<String> imgUrls = await ImageServices().uploadImages(
      path: "display_pic",
      onError: () {
        setState(() {
          processing = false;
        });

        CommunicationServices().showSnackBar(
          "There was an error in uploading the Profile Images. Please check your internet connection and try again",
          context,
        );
      },
      images: [img],
    );

    if (imgUrls != null && imgUrls.isNotEmpty) {
      uploadableProfPic = imgUrls[0];
    }

    List<String> uploadedImages = await ImageServices().uploadImages(
      path: "user_pics",
      onError: () {
        setState(() {
          processing = false;
        });

        CommunicationServices().showSnackBar(
          "There was an error in uploading the user Images. Please check your internet connection and try again",
          context,
        );
      },
      images: selectedImages,
    );

    Map pp = {};
    widget.user.userData.forEach((key, value) {
      pp.addAll({
        key: value,
      });
    });

    pp.addAll({
      Provider.of<PropertyManagement>(context, listen: false)
          .getCurrentPropertyID(): {
        UserModel.USERNAME: userNameController.text.trim(),
        UserModel.EMAIL: widget.showEmail
            ? emailController.text.trim().isEmpty
                ? null
                : emailController.text.trim()
            : widget.user.email,
        UserModel.IMAGES: uploadedImages,
        UserModel.ADDRESS: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        UserModel.REFEREES: referees,
        UserModel.PROFILEPIC: uploadableProfPic,
        UserModel.GENDER: widget.user.entityUserData.gender,
        UserModel.PHONENUMBER: phoneNumberController.text.trim().isEmpty
            ? null
            : phoneNumberController.text.trim(),
        UserModel.WHATSAPPNUMBER: whatsappNumberController.text.trim().isEmpty
            ? null
            : whatsappNumberController.text.trim(),
      }
    });

    FirebaseFirestore.instance
        .collection(UserModel.DIRECTORY)
        .doc(widget.user.id)
        .update({
      UserModel.USERDATA: pp,
      if (widget.showEmail && emailController.text.trim().isNotEmpty)
        UserModel.EMAIL: emailController.text.trim(),
    }).then((value) {
      if (context.canPop()) {
        Navigator.of(context).pop();
      } else {
        context.pushReplacementNamed(
          RouteConstants.allMyProperties,
        );
      }
    });
  }

  singleDateThing(
    String day,
    TextEditingController startDate,
    TextEditingController stopDate,
  ) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextFormField(
              controller: startDate,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 0,
                  ),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextFormField(
              controller: stopDate,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 0,
                  ),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          )
        ],
      ),
    );
  }

  titleAndSub({
    String title,
    String hint,
    TextInputType type,
    TextEditingController controller,
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
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    keyboardType: type,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      //hintText: hint,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 0)),
                      contentPadding: EdgeInsets.all(10),
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
}
