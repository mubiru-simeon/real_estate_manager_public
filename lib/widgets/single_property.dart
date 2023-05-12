import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'widgets.dart';

class SingleProperty extends StatefulWidget {
  final Property property;
  final bool selectable;
  final String propertyID;
  final dynamic price;
  final bool horizontal;
  final bool selected;
  final Function onTap;
  SingleProperty({
    Key key,
    @required this.property,
    @required this.selectable,
    @required this.propertyID,
    this.price,
    @required this.selected,
    @required this.onTap,
    this.horizontal,
  }) : super(key: key);

  @override
  State<SingleProperty> createState() => _SinglePropertyState();
}

class _SinglePropertyState extends State<SingleProperty> {
  int imageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return widget.property == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Property.DIRECTORY)
                .doc(widget.propertyID)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.data() == null) {
                  return DeletedItem(
                    what: "Property",
                    thingID: widget.propertyID,
                  );
                } else {
                  Property model = Property.fromSnapshot(
                    snapshot.data,
                  );

                  return body(model);
                }
              } else {
                return LoadingWidget();
              }
            })
        : body(
            widget.property,
          );
  }

  body(Property property) {
    return Container(
      width: widget.horizontal != null && widget.horizontal
          ? MediaQuery.of(context).size.width * 0.7
          : null,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      margin: EdgeInsets.all(4),
      child: Stack(
        children: [
          Material(
            elevation: standardElevation,
            borderRadius: standardBorderRadius,
            child: GestureDetector(
                onTap: () {
                  if (property.accessible) {
                    if (widget.selectable) {
                      widget.onTap();
                    } else {
                      if (widget.onTap != null) {
                        widget.onTap();
                      } else {
                        context.pushNamed(
                          RouteConstants.property,
                          extra: property,
                          params: {
                            "id": property.id,
                          },
                        );
                      }
                    }
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: standardBorderRadius,
                        child: Container(
                          decoration: BoxDecoration(
                            image: UIServices().decorationImage(
                              property.images.isEmpty
                                  ? compound
                                  : property.images[0],
                              true,
                            ),
                          ),
                          child: Stack(
                            children: [
                              if (property.images.isNotEmpty)
                                Carousel(
                                  dotSpacing: 15,
                                  dotIncreaseSize: 1.3,
                                  dotSize: 8,
                                  autoplay: false,
                                  dotColor: Colors.grey,
                                  dotIncreasedColor: Colors.white,
                                  onImageChange: (v, b) {
                                    setState(() {
                                      imageIndex = b;
                                    });
                                  },
                                  overlayShadow: false,
                                  images: property.images
                                      .map(
                                        (e) => SingleImage(
                                          image: e,
                                        ),
                                      )
                                      .toList(),
                                ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (widget.selected != null &&
                                        widget.selected)
                                      SelectorThingie(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  property.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (property.description != null)
                                  Text(
                                    property.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (property.address != null)
                                  Text(
                                    property.address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                if (property.price != null)
                                  Text(
                                    "UGX ${TextService().putCommas(
                                      widget.price.toString(),
                                    )}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        RatingDisplayer(
                          thingID: property.id,
                        ),
                      ],
                    ),
                  ],
                )),
          ),
          if (!property.accessible)
            ClipRRect(
              borderRadius: standardBorderRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200.withOpacity(
                      0.5,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'The property named ${property.name} is currently in-accessible. Please contact the System admins to find out why.',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            StorageServices().launchTheThing(
                              "tel:$dorxPhoneNumber",
                            );
                          },
                          child: Text(
                            "Contact us",
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
