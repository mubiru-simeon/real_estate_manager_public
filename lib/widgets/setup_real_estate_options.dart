import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../views/views.dart';
import 'widgets.dart';

class SetupPropertyRealEstateOptions extends StatefulWidget {
  final Property property;

  SetupPropertyRealEstateOptions({
    Key key,
    @required this.property,
  }) : super(key: key);

  @override
  State<SetupPropertyRealEstateOptions> createState() =>
      _SetupPropertyRealEstateOptionsState();
}

class _SetupPropertyRealEstateOptionsState
    extends State<SetupPropertyRealEstateOptions> {
  String _houseType;
  Map houseRules = {};
  List images = [];
  Map additionalHouseRules = {};
  String _sharedWithWho;
  String categoryType;
  List<String> _wellbeingAmenities = [];
  List<String> _luxuryAmenities = [];
  List<String> _securityAmenities = [];
  bool petsAllowed = true;
  bool shuttle = false;
  String frequency = PERNIGHT;
  List selectedCategory = [];
  TextEditingController buttonTextController = TextEditingController();
  int _currentIndex = 0;
  TextEditingController propertyNameController = TextEditingController();
  TextEditingController propertyDescriptionController = TextEditingController();
  PageController pageController = PageController();
  bool processing = false;
  String _tenureSystem = "mailo";
  List<Widget> pages;
  String nearbyUniversity;

  @override
  void initState() {
    super.initState();

    setInitialData();
  }

  setInitialData() {
    _tenureSystem = widget.property.tenure;
    nearbyUniversity = widget.property.nearbyUniversity;
    buttonTextController = TextEditingController(
      text: widget.property.buttonText,
    );
    categoryType = widget.property.categoryType;

    _houseType = widget.property.houseType;

    frequency = widget.property.frequency;
    images = widget.property.images;

    widget.property.houseRules.forEach((k, v) {
      houseRules.addAll({k: v});
    });

    for (var v in widget.property.wellbeingAmenities) {
      _wellbeingAmenities.add(v);
    }
    for (var v in widget.property.luxuryAmenities) {
      _luxuryAmenities.add(v);
    }
    for (var v in widget.property.securityAmenities) {
      _securityAmenities.add(v);
    }

    widget.property.additionalRules.forEach((k, v) {
      additionalHouseRules.addAll({k: v});
    });

    for (var element in widget.property.cateogry) {
      selectedCategory.add(element);
    }

    _sharedWithWho = widget.property.sharedWithWho;
    petsAllowed = widget.property.petsAllowed;
    shuttle = widget.property.shuttle;
    propertyNameController = TextEditingController(
      text: widget.property.name,
    );
    propertyDescriptionController = TextEditingController(
      text: widget.property.description,
    );
  }

  @override
  Widget build(BuildContext context) {
    pages = [
      whatKindOfPlace(),
      petAndHouseRulesOptions(),
      addImagesView(),
      demiLevelSelectorPage(),
      categorySelector(),
      welbeingAmenitiesAvailable(),
      luxuryAmenitiesAvailable(),
      securityAmenitiesAvailable(),
      propertyIdentity(),
      propertyDescription(),
      propertyFinalise(),
    ];

    return WillPopScope(
      onWillPop: () {
        return handleBackButton();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              BackBar(
                icon: _currentIndex == 0 ? Icons.close : null,
                onPressed: _currentIndex == 0
                    ? null
                    : () {
                        goBack();
                      },
                text: "Add More Real Estate Options",
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
                    children: pages.map((e) => e).toList(),
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Row(
                children: [
                  Expanded(
                    child: ProceedButton(
                      onTap: () {
                        checkIfItsSafeToProceed();
                      },
                      processing: processing,
                      enablable: false,
                      borderRadius: standardBorderRadius,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentIndex == pages.length - 1
                                ? "Submit Property"
                                : "Proceed",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  propertyIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeadLineText(
          plain: true,
          onTap: null,
          text: "Name your Property.",
        ),
        SizedBox(
          height: 5,
        ),
        TextFormField(
          maxLines: 5,
          controller: propertyNameController,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: "eg: Lisa's Casa",
            hintStyle: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  propertyDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeadLineText(
          plain: true,
          onTap: null,
          text: "Describe your place.",
        ),
        SizedBox(
          height: 5,
        ),
        TextFormField(
          maxLines: 6,
          controller: propertyDescriptionController,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: "Make it appealing and attractive to the customer",
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  luxuryAmenitiesAvailable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: PaginateFirestore(
            isLive: true,
            header: SliverList(
              delegate: SliverChildListDelegate([
                HeadLineText(
                  onTap: null,
                  text:
                      "How about these luxury amenities? (You can select multiple)",
                  plain: true,
                ),
                SizedBox(
                  height: 5,
                ),
              ]),
            ),
            itemBuilder: (
              context,
              snapshot,
              index,
            ) {
              Amenity amenity = Amenity.fromSnapshot(snapshot[index]);

              return SingleAmenity(
                amenity: amenity,
                amenityText: amenity.name,
                onTap: () {
                  setState(() {
                    if (_luxuryAmenities.contains(amenity.id)) {
                      _luxuryAmenities.remove(amenity.id);
                    } else {
                      _luxuryAmenities.add(amenity.id);
                    }
                  });
                },
                selected: _luxuryAmenities.contains(
                  amenity.id,
                ),
              );
            },
            query:
                FirebaseFirestore.instance.collection(Amenity.DIRECTORY).where(
                      Amenity.CATEGORY,
                      isEqualTo: LUXURY,
                    ),
            itemsPerPage: 4,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilderType: PaginateBuilderType.gridView,
          ),
        )
      ],
    );
  }

  securityAmenitiesAvailable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: PaginateFirestore(
            isLive: true,
            header: SliverList(
              delegate: SliverChildListDelegate([
                HeadLineText(
                  onTap: null,
                  text: "How about security? (You can select multiple)",
                  plain: true,
                ),
                SizedBox(
                  height: 5,
                ),
              ]),
            ),
            itemBuilder: (
              context,
              snapshot,
              index,
            ) {
              Amenity amenity = Amenity.fromSnapshot(snapshot[index]);

              return SingleAmenity(
                amenity: amenity,
                amenityText: amenity.name,
                onTap: () {
                  setState(() {
                    if (_securityAmenities.contains(amenity.id)) {
                      _securityAmenities.remove(amenity.id);
                    } else {
                      _securityAmenities.add(amenity.id);
                    }
                  });
                },
                selected: _securityAmenities.contains(
                  amenity.id,
                ),
              );
            },
            query:
                FirebaseFirestore.instance.collection(Amenity.DIRECTORY).where(
                      Amenity.CATEGORY,
                      isEqualTo: SECURITY,
                    ),
            itemsPerPage: 4,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilderType: PaginateBuilderType.gridView,
          ),
        )
      ],
    );
  }

  welbeingAmenitiesAvailable() {
    return PaginateFirestore(
      isLive: true,
      header: SliverList(
        delegate: SliverChildListDelegate([
          HeadLineText(
            onTap: null,
            text:
                "Guests love to feel comfortable. Which of these do you offer? (You can select multiple)",
            plain: true,
          ),
          SizedBox(
            height: 5,
          ),
        ]),
      ),
      itemBuilder: (
        context,
        snapshot,
        index,
      ) {
        Amenity amenity = Amenity.fromSnapshot(snapshot[index]);

        return SingleAmenity(
          amenityText: amenity.name,
          amenity: amenity,
          onTap: () {
            setState(() {
              if (_wellbeingAmenities.contains(amenity.id)) {
                _wellbeingAmenities.remove(amenity.id);
              } else {
                _wellbeingAmenities.add(amenity.id);
              }
            });
          },
          selected: _wellbeingAmenities.contains(
            amenity.id,
          ),
        );
      },
      query: FirebaseFirestore.instance.collection(Amenity.DIRECTORY).where(
            Amenity.CATEGORY,
            isEqualTo: WELLBEING,
          ),
      itemsPerPage: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilderType: PaginateBuilderType.gridView,
    );
  }

  categorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        StatisticText(
          title: "Which category is this?",
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: PaginateFirestore(
            isLive: true,
            itemBuilder: (context, snapshot, index) {
              EntityCategory bb = EntityCategory.fromSnapshot(snapshot[index]);

              bool selected = selectedCategory.contains(bb.id);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedCategory.contains(bb.id)) {
                      selectedCategory.remove(bb.id);
                    } else {
                      selectedCategory.add(bb.id);
                    }
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selected ? Colors.green : primaryColor,
                    borderRadius: standardBorderRadius,
                  ),
                  child: Center(
                    child: Text(
                      bb.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
            query: FirebaseFirestore.instance
                .collection(EntityCategory.DIRECTORY)
                .where(
                  EntityCategory.THINGTYPE,
                  isEqualTo: ThingType.PROPERTY,
                )
                .where(
                  EntityCategory.CATEGORYTYPE,
                  isEqualTo: categoryType,
                )
                .orderBy(
                  EntityCategory.NAME,
                ),
            itemBuilderType: PaginateBuilderType.gridView,
          ),
        ),
      ],
    );
  }

  demiLevelSelectorPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        StatisticText(
          title: "Which kind of property is this?",
        ),
        SizedBox(
          height: 10,
        ),
        SingleSelectTile(
          onTap: () {
            setState(() {
              categoryType = Property.RESIDENTIAL;
            });
          },
          selected: categoryType == Property.RESIDENTIAL,
          text: Property.RESIDENTIAL.capitalizeFirstOfEach,
        ),
        SizedBox(
          height: 10,
        ),
        SingleSelectTile(
          onTap: () {
            setState(() {
              categoryType = Property.COMMERCIAL;
            });
          },
          selected: categoryType == Property.COMMERCIAL,
          text: Property.COMMERCIAL.capitalizeFirstOfEach,
        ),
      ],
    );
  }

  addImagesView() {
    return Column(
      children: [
        HeadLineText(
          plain: true,
          onTap: null,
          text: "Let's Showcase this property with some images.",
        ),
        SizedBox(
          height: 10,
        ),
        ImagePickerWidget(
          images: images,
          noSliver: true,
          pickImages: () async {
            List pp = await ImageServices().pickImages(
              context,
              limit: 10,
            );

            if (pp != null && pp.isNotEmpty) {
              setState(() {
                for (var element in pp) {
                  images.add(element);
                }
              });
            }
          },
        ),
      ],
    );
  }

  whatKindOfPlace() {
    return Column(
      children: [
        HeadLineText(
          plain: true,
          onTap: null,
          text: "What kind of Space is being offered",
        ),
        Column(
          children: houseOptions.entries.map(
            (e) {
              return Padding(
                padding: const EdgeInsets.all(4),
                child: Material(
                  color: selected(true, e.key) ? Colors.green : null,
                  borderRadius: standardBorderRadius,
                  elevation: 8,
                  child: e.value.isEmpty
                      ? ListTile(
                          onTap: () {
                            setState(() {
                              _houseType = e.key;
                              _sharedWithWho = null;
                            });
                          },
                          title: Text(
                            getTileText(e.key),
                            style: TextStyle(
                                color:
                                    selected(true, e.key) ? Colors.white : null,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : ExpansionTile(
                          title: Text(getTileText(e.key)),
                          subtitle: _houseType == SHAREDROOM
                              ? Text("SELECTED")
                              : null,
                          children: e.value["content"].map<Widget>(
                            (v) {
                              return Padding(
                                padding: const EdgeInsets.all(3),
                                child: Material(
                                  color:
                                      selected(false, v) ? Colors.green : null,
                                  elevation: 5,
                                  borderRadius: standardBorderRadius,
                                  child: ListTile(
                                    onTap: () {
                                      setState(() {
                                        _houseType = SHAREDROOM;
                                        _sharedWithWho = v;
                                      });
                                    },
                                    title: Text(
                                      getTileText(v),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selected(false, v)
                                            ? Colors.white
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                ),
              );
            },
          ).toList(),
        )
      ],
    );
  }

  bool selected(bool top, String text) {
    return top
        ? _houseType == text && _houseType != SHAREDROOM
        : _houseType == SHAREDROOM && _sharedWithWho == text;
  }

  petAndHouseRulesOptions() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          CustomDivider(),
          SingleRowSwitchThing(
            text: "Pets are allowed",
            selected: petsAllowed,
            onTap: (b) {
              setState(() {
                petsAllowed = b;
              });
            },
            icon: FontAwesomeIcons.paw,
          ),
          CustomDivider(),
          ListTile(
            leading: Icon(Icons.rule_sharp),
            title: Text(
              "House Rules",
            ),
            subtitle: Text("Tap here to edit the rules"),
            onTap: () async {
              Map pp = await UIServices().showDatSheet(
                SetRulesBottomSheet(
                  existingRules: houseRules,
                  additionalRules: additionalHouseRules,
                ),
                true,
                context,
              );

              if (pp != null) {
                setState(() {
                  houseRules = pp[HouseRules.HOUSERULES] ?? {};
                  additionalHouseRules = pp[HouseRules.ADDITIONALRULES] ?? {};
                });
              }
            },
            trailing: Icon(
              Icons.chevron_right,
            ),
          ),
          Column(
            children: houseRules.entries.map<Widget>((e) {
              HouseRules rule = HouseRules.fromMap(
                e.key,
                e.value[HouseRules.PROHIBITED],
              );

              return singleRule(
                rule,
                houseRules,
              );
            }).followedBy(
              additionalHouseRules.entries.map<Widget>((e) {
                HouseRules rule = HouseRules.fromMap(
                  e.key,
                  e.value[HouseRules.PROHIBITED],
                );

                return singleRule(
                  rule,
                  additionalHouseRules,
                );
              }),
            ).toList(),
          ),
          CustomDivider(),
          SizedBox(
            height: 20,
          ),
          Text(
            "If you want your property to be used for Students' accomodation, fill in this part.",
          ),
          SizedBox(
            height: 5,
          ),
          Column(
            children: [
              CustomDivider(),
              nearbyUniversity == null
                  ? ListTile(
                      onTap: () async {
                        String mat = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return AllUniversitiesView(
                                selectable: true,
                              );
                            },
                          ),
                        );

                        setState(() {
                          if (mat == null) {
                            nearbyUniversity = null;
                          } else {
                            nearbyUniversity = mat;
                          }
                        });
                      },
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                      ),
                      leading: CircleAvatar(
                        child: Icon(
                          FontAwesomeIcons.graduationCap,
                        ),
                      ),
                      title: Text(
                        "Which education institute is near your property?",
                      ),
                      subtitle: Text(
                        "Tap here to select the institute.",
                      ),
                    )
                  : StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection(SchoolModel.DIRECTORY)
                          .doc(nearbyUniversity)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return LoadingWidget();
                        } else {
                          SchoolModel university =
                              SchoolModel.fromSnapshot(snapshot.data);

                          return ListTile(
                            onTap: () async {
                              String mat = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AllUniversitiesView(
                                      selectable: true,
                                    );
                                  },
                                ),
                              );

                              setState(() {
                                nearbyUniversity = mat;
                              });
                            },
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                            ),
                            leading: CircleAvatar(
                              backgroundImage: UIServices().getImageProvider(
                                university.image ?? bedroom,
                              ),
                            ),
                            title: Text(
                              university.name.toUpperCase(),
                            ),
                          );
                        }
                      },
                    ),
              CustomDivider(),
              SingleRowSwitchThing(
                text: "We have a shuttle",
                selected: shuttle,
                onTap: (b) {
                  setState(() {
                    shuttle = b;
                  });
                },
                icon: FontAwesomeIcons.bus,
              ),
              CustomDivider(),
            ],
          )
        ],
      ),
    );
  }

  singleRule(
    HouseRules rule,
    Map pp,
  ) {
    return ListTile(
      title: Text(rule.name),
      trailing: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (pp.containsKey(rule.name)) {
                      if (pp[rule.name][HouseRules.PROHIBITED]) {
                        pp.addAll({
                          rule.name: {
                            HouseRules.PROHIBITED: false,
                          }
                        });
                      } else {
                        pp.remove(rule.name);
                      }
                    } else {
                      pp.addAll({
                        rule.name: {
                          HouseRules.PROHIBITED: false,
                        }
                      });
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: pp.containsKey(rule.name) &&
                            pp[rule.name][HouseRules.PROHIBITED] == false
                        ? Colors.green
                        : null,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.done,
                      color: pp.containsKey(rule.name) &&
                              pp[rule.name][HouseRules.PROHIBITED] == false
                          ? Colors.white
                          : null),
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(
                    () {
                      if (pp.containsKey(rule.name)) {
                        if (pp[rule.name][HouseRules.PROHIBITED] == false) {
                          pp.addAll({
                            rule.name: {
                              HouseRules.PROHIBITED: true,
                            }
                          });
                        } else {
                          pp.remove(rule.name);
                        }
                      } else {
                        pp.addAll({
                          rule.name: {
                            HouseRules.PROHIBITED: true,
                          }
                        });
                      }
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: pp.containsKey(rule.name) &&
                            pp[rule.name][HouseRules.PROHIBITED] == true
                        ? Colors.red
                        : null,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    color: pp.containsKey(rule.name) &&
                            pp[rule.name][HouseRules.PROHIBITED] == true
                        ? Colors.white
                        : null,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(
                    () {
                      pp.remove(
                        rule.name,
                      );
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  checkIfItsSafeToProceed() {
    if (_currentIndex == 0 && _houseType == null) {
      CommunicationServices().showSnackBar(
        "Please tell us what exactly you're offering.",
        context,
      );
    } else if (_currentIndex == 8 &&
        propertyNameController.text.trim().isEmpty) {
      CommunicationServices().showSnackBar(
        "Please tell us the property name.",
        context,
      );
    } else if (_currentIndex == 9 &&
        propertyDescriptionController.text.trim().isEmpty) {
      CommunicationServices().showSnackBar(
        "Please provide a description.",
        context,
      );
    } else if (_currentIndex == 3 && categoryType == null) {
      CommunicationServices().showSnackBar(
        "Please tell us which kind of property this is.",
        context,
      );
    } else if (_currentIndex == 4 && selectedCategory.isEmpty) {
      CommunicationServices().showSnackBar(
        "Please tell us which kind of property this is.",
        context,
      );
    } else if (_currentIndex == pages.length - 1) {
      if (AuthProvider.of(context).auth.isSignedIn()) {
        updateProperty();
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return NotLoggedInDialogBox(
              onLoggedIn: () {
                updateProperty();
              },
            );
          },
        );
      }
    } else {
      goNext();
    }
  }

  updateProperty() async {
    setState(() {
      processing = true;
    });

    List pp = await ImageServices().uploadImages(
      path: "property_images",
      onError: () {
        setState(() {
          processing = false;
        });

        CommunicationServices().showToast(
          "Erorr uploading images. Please try again",
          Colors.red,
        );
      },
      images: images,
    );

    FirebaseFirestore.instance
        .collection(Property.DIRECTORY)
        .doc(widget.property.id)
        .update({
      Property.HOUSERULES: houseRules,
      Property.ADDITIONALHOUSERULES: additionalHouseRules,
      Property.PETSALLOWED: petsAllowed,
      Property.SHAREDWITHWHO: _sharedWithWho,
      Property.HOUSETYPE: _houseType,
      Property.CATEGORY: selectedCategory,
      Property.IMAGES: pp,
      Property.SHUTTLE: shuttle,
      Property.WELLBEINGAMENITIES: _wellbeingAmenities,
      Property.SECURITYAMENITIES: _securityAmenities,
      Property.LUXURYAMENITIES: _luxuryAmenities,
      Property.NAME: propertyNameController.text.trim(),
      Property.DESCRIPTION: propertyDescriptionController.text.trim(),
      Property.BUTTONTEXT: buttonTextController.text.trim().isEmpty
          ? null
          : buttonTextController.text.trim(),
      Property.FREQUENCY: frequency,
      Property.TENURE: _tenureSystem,
      Property.CATEGORYTYPE: categoryType,
      Property.NEARBYUNIVERSITY: nearbyUniversity,
    }).then((value) {
      Navigator.of(context).pop();

      CommunicationServices().showSnackBar(
        "The property has been successfully updated.",
        context,
      );
    }).catchError((b) {
      setState(() {
        processing = false;
      });

      CommunicationServices().showToast(
        "There was an error uploading the property :$b",
        Colors.red,
      );
    });
  }

  propertyFinalise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          "Congratulations. Your Property is ready to be published on Dorx. Let's get this party on the road.",
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          "[OPTIONAL] One last thing. You can edit the ka word that shows on the booking button. Just to customize the experience for your clients and stand out. It's entirely optional and if you don't edit it, the default is \"Book a room\"",
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          controller: buttonTextController,
          decoration: InputDecoration(
            hintText: "Book a room (default)",
          ),
        )
      ],
    );
  }

  goNext() {
    pageController.animateToPage(
      (pageController.page + 1).toInt(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  goBack() {
    pageController.animateToPage(
      (pageController.page - 1).toInt(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  handleBackButton() {
    if (_currentIndex != 0) {
      goBack();
    } else {
      Navigator.of(context).pop();
    }
  }
}
