import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'widgets.dart';

class AddACustomerBottomSheet extends StatefulWidget {
  final bool returning;
  AddACustomerBottomSheet({
    Key key,
    @required this.returning,
  }) : super(key: key);

  @override
  State<AddACustomerBottomSheet> createState() =>
      _AddACustomerBottomSheetState();
}

const male = "male";
const female = "female";
const other = "other";

class _AddACustomerBottomSheetState extends State<AddACustomerBottomSheet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController whatsappNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  PageController pageController = PageController();
  List images = [];
  Box box;
  bool autoAddNumber = false;
  List<Map> referees = [];
  String gender = male;
  String type = ThingType.CUSTOMER;
  bool processing = false;
  bool haveEmail = true;

  List<String> genders = [
    male,
    female,
    other,
  ];

  int _currentIndex = 0;
  List<Widget> pages;

  @override
  void initState() {
    super.initState();
    box = Hive.box(DorxSettings.DORXBOXNAME);

    DorxSettings settings = DorxSettings.fromMap(
      box.get(DorxSettings.SETTINGSMAP),
      null,
    );

    autoAddNumber = settings.autoAddNumbers;
  }

  @override
  Widget build(BuildContext context) {
    pages = [
      namePage(),
      if (haveEmail) emailPage(),
      detailsPage(),
    ];

    return WillPopScope(
      onWillPop: () {
        return handleBackButton();
      },
      child: Scaffold(
        body: MyKeyboardListenerWidget(
          proceed: () {
            checkIfItsSafeToProceed();
          },
          child: Column(
            children: [
              BackBar(
                icon: _currentIndex == 0 ? Icons.close : null,
                onPressed: _currentIndex == 0
                    ? null
                    : () {
                        goBack();
                      },
                text: "Add New Expense",
              ),
              Row(
                children: pages.map((e) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 1,
                      ),
                      height: 5,
                      color: _currentIndex >= pages.indexOf(e)
                          ? primaryColor
                          : Colors.grey,
                    ),
                  );
                }).toList(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    onPageChanged: (v) {
                      setState(() {
                        _currentIndex = v;
                      });
                    },
                    controller: pageController,
                    children: pages,
                  ),
                ),
              ),
              ProceedButton(
                processing: processing,
                onTap: () {
                  checkIfItsSafeToProceed();
                },
                text: "Proceed",
              ),
            ],
          ),
        ),
      ),
    );
  }

  handleBackButton() {
    if (_currentIndex != 0) {
      goBack();
    } else {
      Navigator.of(context).pop();
    }
  }

  goBack() {
    pageController.animateToPage(
      (pageController.page - 1).toInt(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  emailPage() {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 10,
        ),
        StatisticText(
          title: "Enter the email",
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: translation(context).email,
            suffixIcon: Icon(
              Icons.email,
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ]),
    );
  }

  detailsPage() {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 10,
        ),
        Text(
          translation(context).fieldsMarkedWithStar,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          translation(context).gender,
          style: titleStyle,
        ),
        SizedBox(
          height: 100,
          child: Row(
            children: genders
                .map(
                  (e) => Expanded(
                    child: RowSelector(
                      selected: gender == e,
                      onTap: () {
                        setState(() {
                          gender = e;
                        });
                      },
                      text: e.toUpperCase(),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          controller: phoneNumberController,
          decoration: InputDecoration(
            hintText: translation(context).phoneNumber,
            suffixIcon: Icon(
              FontAwesomeIcons.phoneFlip,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          controller: whatsappNumberController,
          decoration: InputDecoration(
              hintText: translation(context).whatsappNumber,
              suffixIcon: Icon(FontAwesomeIcons.whatsapp)),
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          controller: addressController,
          decoration: InputDecoration(
            suffixIcon: Icon(
              FontAwesomeIcons.addressBook,
            ),
            hintText: translation(context).address,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        ImagePickerWidget(
          images: images,
          text: "[OPTIONAL] Pictures",
          crossAxisCount: 2,
          pickImages: () async {
            List tempImages = await ImageServices().pickImages(
              context,
              limit: 10,
            );

            if (tempImages.isNotEmpty) {
              setState(() {
                for (var element in tempImages) {
                  images.add(element);
                }
              });
            }
          },
          noSliver: true,
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
                title: translation(context).addAReferee,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          Row(
                            children: [
                              Expanded(
                                child: SingleBigButton(
                                  text: "Edit",
                                  color: Colors.green,
                                  onPressed: () async {
                                    Map pp = await UIServices().showDatSheet(
                                      CustomerDetailsBottomSheet(
                                        title: "Edit Personal Information",
                                      ),
                                      true,
                                      context,
                                    );

                                    if (pp != null && pp.isNotEmpty) {
                                      setState(
                                        () {
                                          referees.remove(e);

                                          referees.add(pp);
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                child: SingleBigButton(
                                  text: "Remove",
                                  color: Colors.red,
                                  onPressed: () async {
                                    setState(
                                      () {
                                        referees.remove(e);
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
          height: 50,
        ),
      ]),
    );
  }

  namePage() {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 10,
        ),
        StatisticText(
          title: "Enter the name",
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: translation(context).firstName,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        CustomDivider(),
        CheckboxListTile(
          value: haveEmail,
          title: Text(
            "This user has an email",
          ),
          onChanged: (v) {
            setState(() {
              haveEmail = v;
            });
          },
        ),
        CustomDivider(),
        SizedBox(
          height: 10,
        ),
      ]),
    );
  }

  checkIfItsSafeToProceed() {
    if (_currentIndex == 0 && nameController.text.trim().isEmpty) {
      CommunicationServices().showSnackBar(
        "You need to provide your user's name.",
        context,
      );
    } else {
      if (_currentIndex == 1 &&
          haveEmail &&
          emailController.text.trim().isEmpty) {
        CommunicationServices().showToast(
          "Pleaze provide the email",
          Colors.red,
        );
      } else {
        if (_currentIndex == 1 &&
            haveEmail &&
            emailController.text.trim().isNotEmpty) {
          setState(() {
            processing = true;
          });

          FirebaseFirestore.instance
              .collection(UserModel.DIRECTORY)
              .where(
                UserModel.EMAIL,
                isEqualTo: emailController.text.trim(),
              )
              .get()
              .then(
            (value) {
              setState(() {
                processing = false;
              });
              if (value.docs.isEmpty) {
                goNext();
              } else {
                showDialog(
                    context: context,
                    builder: (context) {
                      return CustomDialogBox(
                        bodyText: null,
                        buttonText: null,
                        onButtonTap: () {},
                        showOtherButton: true,
                        child: Column(children: [
                          Text(
                            "There's already a user with this exact same email. Tap here to view his account.",
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ProceedButton(
                            onTap: () {
                              UserModel user = UserModel.fromSnapshot(
                                value.docs[0],
                                Provider.of<PropertyManagement>(
                                  context,
                                  listen: false,
                                ).getCurrentPropertyID(),
                              );

                              context.pushNamed(
                                RouteConstants.user,
                                extra: user,
                                params: {
                                  "id": user.id,
                                },
                              );
                            },
                            text: "View Profile",
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ProceedButton(
                            onTap: () {
                              UserModel user = UserModel.fromSnapshot(
                                value.docs[0],
                                Provider.of<PropertyManagement>(
                                  context,
                                  listen: false,
                                ).getCurrentPropertyID(),
                              );

                              Map pp = {};
                              user.userData.forEach((key, value) {
                                pp.addAll({
                                  key: value,
                                });
                              });

                              pp.addAll({
                                Provider.of<PropertyManagement>(context,
                                        listen: false)
                                    .getCurrentPropertyID(): {
                                  UserModel.USERNAME:
                                      nameController.text.trim(),
                                  UserModel.EMAIL:
                                      emailController.text.trim().isEmpty
                                          ? null
                                          : emailController.text.trim(),
                                  UserModel.IMAGES: user.entityUserData.images,
                                  UserModel.ADDRESS:
                                      user.entityUserData.address,
                                  UserModel.PROFILEPIC:
                                      user.entityUserData.profilePic,
                                  UserModel.GENDER: gender,
                                }
                              });

                              List currentAffiliations = [];
                              for (var element in user.affiliations) {
                                currentAffiliations.add(element);
                              }

                              currentAffiliations
                                  .add(Provider.of<PropertyManagement>(
                                context,
                                listen: false,
                              ).getCurrentPropertyID());

                              FirebaseFirestore.instance
                                  .collection(UserModel.DIRECTORY)
                                  .doc(user.id)
                                  .update({
                                UserModel.USERDATA: pp,
                                UserModel.AFFILIATION: currentAffiliations,
                              });

                              Navigator.of(context).pop();

                              CommunicationServices().showToast(
                                widget.returning
                                    ? "Selected the user ${user.userName}"
                                    : "Added ${user.userName} to your customers",
                                primaryColor,
                              );

                              Navigator.of(context).pop(
                                widget.returning ? user.id : null,
                              );
                            },
                            text: widget.returning
                                ? "Select this user"
                                : "Add this person to my customers",
                          ),
                        ]),
                      );
                    });
              }
            },
          ).timeout(
            Duration(seconds: 10),
            onTimeout: () {
              setState(() {
                processing = false;
              });

              CommunicationServices().showToast(
                "Error checking the email. Please check your internet connection.",
                Colors.red,
              );
            },
          );
        } else {
          if (_currentIndex == pages.length - 1) {
            gh();
          } else {
            goNext();
          }
        }
      }
    }
  }

  goNext() {
    pageController.animateToPage(
      (pageController.page + 1).toInt(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  gh() async {
    setState(() {
      processing = true;
    });

    List<String> imgUrls = await ImageServices().uploadImages(
      images: images,
      path: "user_images",
      onError: () {
        CommunicationServices().showSnackBar(
          "There was an error in uploading the user's images. Please check your internet connection and try again.",
          context,
        );

        setState(() {
          processing = false;
        });
      },
    );

    if (processing) {
      if (autoAddNumber) {
        FirebaseDatabase.instance
            .ref()
            .child(UserModel.CUSTOMERCOUNT)
            .child(
              Provider.of<PropertyManagement>(context, listen: false)
                  .getCurrentPropertyID(),
            )
            .get()
            .then((v) {
          int dd = 1;

          if (v.value != null) {
            dd = v.value;
          }

          nameController = TextEditingController(
            text: "$dd ${nameController.text}",
          );

          createUser(imgUrls);

          FirebaseDatabase.instance.ref().child(UserModel.CUSTOMERCOUNT).update(
            {
              Provider.of<PropertyManagement>(context, listen: false)
                  .getCurrentPropertyID(): (dd + 1)
            },
          );
        });
      } else {
        createUser(imgUrls);
      }
    }
  }

  createUser(
    List imgUrls,
  ) {
    StorageServices().createNewUser(
      type: type,
      property: Provider.of<PropertyManagement>(
        context,
        listen: false,
      ).getCurrentPropertyID(),
      registerer: AuthProvider.of(context).auth.getCurrentUID(),
      phoneNumber: phoneNumberController.text.trim().isEmpty
          ? null
          : phoneNumberController.text.trim(),
      email: emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
      uid: null,
      referees: referees,
      userName: nameController.text.trim().isEmpty
          ? null
          : nameController.text.trim(),
      gender: gender,
      images: imgUrls,
      whatsappNumber: whatsappNumberController.text.trim().isEmpty
          ? null
          : whatsappNumberController.text.trim(),
      address: addressController.text.trim().isEmpty
          ? null
          : addressController.text.trim(),
    );

    CommunicationServices().showSnackBar(
      "Successfully created the user.",
      context,
    );

    Navigator.of(context).pop();
  }
}

class AddReferenceBottomSheet extends StatefulWidget {
  AddReferenceBottomSheet({Key key}) : super(key: key);

  @override
  State<AddReferenceBottomSheet> createState() =>
      _AddReferenceBottomSheetState();
}

class _AddReferenceBottomSheetState extends State<AddReferenceBottomSheet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "Add a Referee",
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Name",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Wrap(children: [
        ProceedButton(
          onTap: () {},
          text: "Finish",
        ),
      ]),
    );
  }
}
