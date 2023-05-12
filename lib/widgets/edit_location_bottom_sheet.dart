import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dorx/models/delivery_location.dart';
import 'package:dorx/services/communications.dart';
import 'package:dorx/services/location_service.dart';

import '../constants/ui.dart';
import 'informational_box.dart';
import 'proceed_button.dart';
import 'top_back_bar.dart';
import 'transparent_button.dart';

class EditLocationBottomSheet extends StatefulWidget {
  final DeliveryLocation deliveryLocation;

  EditLocationBottomSheet({
    Key key,
    this.deliveryLocation,
  }) : super(key: key);

  @override
  State<EditLocationBottomSheet> createState() =>
      _EditLocationBottomSheetState();
}

class _EditLocationBottomSheetState extends State<EditLocationBottomSheet> {
  TextEditingController controller = TextEditingController();
  LatLng location;
  bool processing = false;

  @override
  void initState() {
    if (widget.deliveryLocation != null) {
      if (widget.deliveryLocation.name != null) {
        controller = TextEditingController(
          text: widget.deliveryLocation.name,
        );
      }

      location = LatLng(
        widget.deliveryLocation.lat,
        widget.deliveryLocation.long,
      );
    }
    super.initState();
  }

  String loc = "Location";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Delivery Location",
        ),
        InformationalBox(
          visible: true,
          onClose: null,
          message: "Here. you can add a new Delivery Location",
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "[OPTIONAL] Name this Location",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TransparentButton(
                    icon: Icon(
                      Icons.add_location,
                    ),
                    text: "Locate Place on the Map",
                    onTap: () async {
                      location = await LocationService().pickLocation(
                        context,
                        selectable: true,
                      );

                      setState(() {});
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (location != null)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 5,
                      ),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                          borderRadius: standardBorderRadius),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Latitude: ${location.latitude}"),
                                Text("Longitude: ${location.longitude}"),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(loc)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        ProceedButton(
          processing: processing,
          onTap: () {
            if (location != null) {
              setState(() {
                processing = true;
              });

              try {
                if (widget.deliveryLocation == null) {
                  LocationService().addLocationToFirebase(
                    context,
                    location,
                    locationID: null,
                    name: controller.text.trim(),
                  );
                } else {
                  LocationService().addLocationToFirebase(
                    context,
                    location,
                    locationID: widget.deliveryLocation.id,
                    name: controller.text.trim(),
                  );
                }

                Navigator.of(context).pop();
              } catch (e) {
                setState(() {
                  processing = false;
                });

                CommunicationServices().showToast(
                  "There was an error uploading the location to the database. Please check your internet collection",
                  Colors.red,
                );
              }
            } else {
              CommunicationServices().showSnackBar(
                "Please provide a location",
                context,
                behavior: SnackBarBehavior.floating,
              );
            }
          },
          text: widget.deliveryLocation != null
              ? "Update Location"
              : "Add Location",
          enablable: false,
        )
      ],
    );
  }
}
