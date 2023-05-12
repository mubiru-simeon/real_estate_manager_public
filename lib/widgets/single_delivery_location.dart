import 'package:flutter/material.dart';
import 'package:dorx/models/delivery_location.dart';
import 'package:dorx/services/ui_services.dart';
import 'package:dorx/theming/theme_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/ui.dart';
import '../services/location_service.dart';
import 'edit_location_bottom_sheet.dart';

class SingleDeliveryLocation extends StatefulWidget {
  final bool selected;
  final Function onTap;
  final DeliveryLocation deliveryLocation;
  SingleDeliveryLocation({
    Key key,
    @required this.deliveryLocation,
    this.onTap,
    @required this.selected,
  }) : super(key: key);

  @override
  State<SingleDeliveryLocation> createState() => _SingleDeliveryLocationState();
}

class _SingleDeliveryLocationState extends State<SingleDeliveryLocation> {
  String loc = "Location";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) widget.onTap();
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 5,
        ),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.selected ? Colors.green : null,
          border: Border.all(
            width: 1,
            color: Colors.grey,
          ),
          borderRadius: standardBorderRadius,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.deliveryLocation.name ?? "Location",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.selected ? Colors.white : null,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: widget.selected ? Colors.white : null,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FutureBuilder(
                          future: LocationService().getAddressFromLatLng(
                            LatLng(
                              widget.deliveryLocation.lat,
                              widget.deliveryLocation.long,
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
                                style: TextStyle(
                                  color: widget.selected ? Colors.white : null,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                PopupMenuButton(
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: ThemeBuilder.of(context).getCurrentTheme() ==
                            Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 1,
                        child: Text("Edit"),
                      ),
                    ];
                  },
                  onSelected: (val) {
                    if (val == 1) {
                      UIServices().showDatSheet(
                        EditLocationBottomSheet(
                          deliveryLocation: widget.deliveryLocation,
                        ),
                        true,
                        context,
                      );
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /*  void _getAddressFromLatLng(LatLng _currentPosition) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = placemarks[0];

      loc =
          "${place.locality}, ${place.postalCode}, ${place.country}, ${place.street}";
    } catch (e) {
     
      loc = "There was an error in generating the location name";
    }
  } */
}
