import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'views.dart';

class DetailedPropertyView extends StatefulWidget {
  final Property property;
  final String propertyID;

  DetailedPropertyView({
    Key key,
    @required this.property,
    @required this.propertyID,
  }) : super(key: key);

  @override
  State<DetailedPropertyView> createState() => _DetailedPropertyViewState();
}

class _DetailedPropertyViewState extends State<DetailedPropertyView> {
  int _currentPicIndex = 0;
  PageController pageController = PageController();
  bool shareProcessing = false;

  @override
  Widget build(BuildContext context) {
    return widget.property == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Property.DIRECTORY)
                .doc(widget.propertyID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Scaffold(
                  body: LoadingWidget(),
                );
              } else {
                Property recipe = Property.fromSnapshot(snapshot.data);

                return body(recipe);
              }
            })
        : body(widget.property);
  }

  body(Property property) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: false,
                pinned: true,
                snap: false,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                expandedHeight: MediaQuery.of(context).size.height * 0.4,
                flexibleSpace: FlexibleSpaceBar(
                  background: property.images.isEmpty
                      ? Image.asset(
                          compound,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          color: Colors.black.withOpacity(0.3),
                          colorBlendMode: BlendMode.darken,
                        )
                      : GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              RouteConstants.image,
                              extra: property.images,
                            );
                          },
                          child: StatefulBuilder(
                            builder: (context, doIt) {
                              return Stack(
                                children: [
                                  Carousel(
                                    images: property.images
                                        .map((e) => SingleImage(image: e))
                                        .toList(),
                                    showIndicator: false,
                                    onImageChange: (o, n) {
                                      doIt(() {
                                        _currentPicIndex = n;
                                      });
                                    },
                                  ),
                                  Positioned(
                                    right: 10,
                                    bottom: 10,
                                    child: SafeArea(
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: altColor.withOpacity(0.5),
                                            border: Border.all(
                                                width: 1, color: altColor),
                                            borderRadius: standardBorderRadius),
                                        child: Text(
                                          "${_currentPicIndex + 1}/${property.images.length}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomSizedBox(
                            sbSize: SBSize.small,
                            height: true,
                          ),
                          Text(
                            property.name ??
                                "Please provide a name for your Property",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: property.name == null ? Colors.red : null,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          CustomSizedBox(
                            sbSize: SBSize.smallest,
                            height: true,
                          ),
                          if (property.description != null)
                            Text(
                              property.description,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          if (property.propertyHeadlines.isNotEmpty) Divider(),
                          if (property.propertyHeadlines.isNotEmpty)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: property.propertyHeadlines
                                    .map(
                                      (e) => Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: SingleHighlight(
                                          text: e,
                                          selected: false,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CustomSizedBox(
                          sbSize: SBSize.smallest,
                          height: false,
                        ),
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CustomSizedBox(
                        sbSize: SBSize.smallest,
                        height: false,
                      ),
                      if (property.houseType != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: ChoiceChip(
                            label: Text(
                              property.houseType.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: true,
                          ),
                        ),
                      if (property.sharedWithWho != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: ChoiceChip(
                            label: Text(
                              property.sharedWithWho.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: true,
                          ),
                        ),
                    ],
                  ),
                )
              ])),
              SliverPadding(
                padding: EdgeInsets.all(10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (property.propertyHeadlines.isNotEmpty) Divider(),
                      if (property.images.isNotEmpty)
                        StatisticText(
                          title: "PHOTOS",
                        ),
                      if (property.images.isNotEmpty)
                        SizedBox(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: property.images
                                  .map(
                                    (e) => GestureDetector(
                                      onTap: () {
                                        context.pushNamed(
                                          RouteConstants.image,
                                          extra: [e],
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: ClipRRect(
                                          borderRadius: standardBorderRadius,
                                          child: SingleImage(
                                            image: e,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.17,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.17,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      if (property.images.isNotEmpty)
                        Divider(
                          height: 30,
                        ),
                      if ((property.wellbeingAmenities.isNotEmpty ||
                          property.luxuryAmenities.isNotEmpty ||
                          property.securityAmenities.isNotEmpty))
                        StatisticText(
                          title: "AMENITIES",
                        ),
                      if ((property.wellbeingAmenities.isNotEmpty))
                        amenity(
                          property.wellbeingAmenities,
                          "WellBeing",
                        ),
                      if (property.luxuryAmenities.isNotEmpty)
                        amenity(
                          property.luxuryAmenities,
                          "Luxury",
                        ),
                      if (property.securityAmenities.isNotEmpty)
                        amenity(
                          property.securityAmenities,
                          "Security",
                        ),
                      Divider(),
                      CustomSizedBox(
                        sbSize: SBSize.small,
                        height: true,
                      ),
                      if (property.lat != null)
                        StatisticText(
                          title: "LOCATION",
                        ),
                      if (property.lat != null)
                        Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: ClipRRect(
                            borderRadius: standardBorderRadius,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: GestureDetector(
                                onTap: () async {},
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: Image(
                                        image: AssetImage(
                                          mapPic,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Spacer(),
                                        Expanded(
                                          child: Container(
                                            color: altColor,
                                            child: Center(
                                              child: Text(
                                                "Tap here to view the location",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (property.lat != null)
                        FutureBuilder(
                          future: LocationService().getAddressFromLatLng(
                            LatLng(
                              property.lat,
                              property.long,
                            ),
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "location loading..",
                              );
                            } else {
                              String place = snapshot.data["text"];

                              return Text(
                                place,
                              );
                            }
                          },
                        ),
                      if (property.lat != null)
                        CustomSizedBox(
                          sbSize: SBSize.small,
                          height: true,
                        ),
                      if (property.lat != null)
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              LocationService().openInGoogleMaps(
                                  property.lat, property.long);
                            },
                            child: Text(
                              "Get Directions in Google Maps",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (property.lat != null)
                        Divider(
                          height: 30,
                        ),
                      StatisticText(
                        title: "ROOMS AND SPACES",
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: PaginateFirestore(
                          itemBuilder: (context, snapshot, index) {
                            RoomType roomType =
                                RoomType.fromSnapshot(snapshot[index]);

                            return Column(
                              children: [
                                Expanded(
                                  child: SingleRoomType(
                                    roomType: roomType,
                                    horizontal: true,
                                    roomTypeID: roomType.id,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Tap here To book",
                                  ),
                                )
                                /* Wrap(
                                children: [
                                  ProceedButton(
                                    onTap: () {},
                                    text: "Tap to Book",
                                  ),
                                ],
                              ) */
                              ],
                            );
                          },
                          isLive: true,
                          onEmpty: NoDataFound(
                            text: "No Rooms Attached Yet",
                          ),
                          query: FirebaseFirestore.instance
                              .collection(RoomType.DIRECTORY)
                              .where(
                                RoomType.PROPERTY,
                                isEqualTo: property.id,
                              ),
                          itemBuilderType: PaginateBuilderType.listView,
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDivider(),
                            ListTile(
                              title: Text(
                                "RATINGS AND REVIEWS",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 15,
                              ),
                              onTap: () {
                                //TODO: Reviews
                              },
                            ),
                            CustomDivider(),
                            CustomSizedBox(
                              sbSize: SBSize.small,
                              height: true,
                            ),
                            StatisticText(
                              title: "More like this",
                            ),
                            // SizedBox(
                            //   height: MediaQuery.of(context).size.height * 0.37,
                            //   child: PaginateFirestore(
                            //     itemBuilder: (
                            //       context,
                            //       snapshot,
                            //       index,
                            //     ) {
                            //       Property recipe = Property.fromSnapshot(
                            //         snapshot[index],
                            //       );

                            //       return SingleProperty(
                            //         property: recipe,
                            //         horizontal: true,
                            //         selected: false,
                            //         selectable: false,
                            //         list: true,
                            //         onTap: null,
                            //         propertyID: recipe.id,
                            //       );
                            //     },
                            //     query: FirebaseFirestore.instance
                            //         .collection(Property.DIRECTORY)
                            //         .where(
                            //           Category.OMEGA,
                            //           isEqualTo: property.omegaLevel,
                            //         )
                            //         .where(
                            //           Category.DEMI,
                            //           isEqualTo: property.demilevel,
                            //         ),
                            //     onEmpty: NoDataFound(
                            //       text: "No Properties Found",
                            //     ),
                            //     itemsPerPage: 2,
                            //     scrollDirection: Axis.horizontal,
                            //     itemBuilderType: PaginateBuilderType.listView,
                            //   ),
                            // ),
                            // CustomSizedBox(
                            //   sbSize: SBSize.small,
                            //   height: true,
                            // ),
                            StatisticText(
                              title: "More from this property manager.",
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.37,
                              child: PaginateFirestore(
                                itemBuilder: (
                                  context,
                                  snapshot,
                                  index,
                                ) {
                                  Property recipe = Property.fromSnapshot(
                                    snapshot[index],
                                  );

                                  return SingleProperty(
                                    property: recipe,
                                    horizontal: true,
                                    selected: false,
                                    selectable: false,
                                    onTap: null,
                                    propertyID: recipe.id,
                                  );
                                },
                                query: FirebaseFirestore.instance
                                    .collection(Property.DIRECTORY)
                                    .where(
                                      Property.OWNER,
                                      arrayContainsAny: property.owners,
                                    ),
                                onEmpty: NoDataFound(
                                  text: "No Properties Found",
                                ),
                                itemsPerPage: 2,
                                scrollDirection: Axis.horizontal,
                                itemBuilderType: PaginateBuilderType.listView,
                              ),
                            ),

                            CustomSizedBox(
                              sbSize: SBSize.largest,
                              height: true,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 5,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: "share_property",
                        onPressed: () async {
                          // setState(() {
                          //   shareProcessing = true;
                          // });

                          // String pp = await DynamicLinkServices().generateLink(
                          //   context: context,
                          //   id: property.id,
                          //   title: property.name,
                          //   desc: property.description ??
                          //       "A lovely venue for you",
                          //   type: ThingType.PROPERTY,
                          //   image: property.images.isEmpty
                          //       ? null
                          //       : property.images[0],
                          //   userID: AuthProvider.of(context).auth.isSignedIn()
                          //       ? AuthProvider.of(context).auth.getCurrentUID()
                          //       : "anon",
                          // );

                          // if (pp != null) {
                          //   Share.share(
                          //     pp,
                          //     subject:
                          //         "Check out this ${ThingType.PROPERTY} from ${appName.capitalizeFirstOfEach}",
                          //   );
                          // }

                          // setState(() {
                          //   shareProcessing = false;
                          // });
                          //TODO: Share property
                        },
                        child: shareProcessing
                            ? CircularProgressIndicator()
                            : Icon(
                                Icons.share,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  amenity(
    List amenities,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatisticText(
            title: text,
          ),
          Wrap(
            children: amenities
                .map(
                  (e) => SingleAmenity(
                    amenity: null,
                    wrap: true,
                    amenityText: e,
                  ),
                )
                .toList(),
          )
        ],
      ),
    );
  }
}
