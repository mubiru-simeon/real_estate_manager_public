// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'dart:convert' as convert;

import '../constants/constants.dart';
import '../models/models.dart';
import '../views/views.dart';
import '../widgets/widgets.dart';
import 'services.dart';

class LocationService {
  addLocationToFirebase(
    BuildContext context,
    LatLng location, {
    String name = "Location",
    @required String locationID,
  }) {
    if (AuthProvider.of(context).auth.isSignedIn()) {
      if (locationID != null) {
        FirebaseFirestore.instance
            .collection(DeliveryLocation.DIRECTORY)
            .doc(AuthProvider.of(context).auth.getCurrentUID())
            .collection(AuthProvider.of(context).auth.getCurrentUID())
            .doc(locationID)
            .update({
          DeliveryLocation.LAT: location.latitude,
          DeliveryLocation.LONG: location.longitude,
          DeliveryLocation.NAME: name.trim().isEmpty ? null : name.trim(),
        });
      } else {
        FirebaseFirestore.instance
            .collection(DeliveryLocation.DIRECTORY)
            .doc(AuthProvider.of(context).auth.getCurrentUID())
            .collection(AuthProvider.of(context).auth.getCurrentUID())
            .add({
          DeliveryLocation.LAT: location.latitude,
          DeliveryLocation.LONG: location.longitude,
          DeliveryLocation.NAME: name.trim().isEmpty ? null : name.trim(),
        });
      }
    }
  }

  Future<void> openInGoogleMaps(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    await StorageServices().launchTheThing(googleUrl);
  }

  Future<List<LatLng>> pickMultipleLocations(BuildContext context,
      {bool selectable, List<LatLng> locations}) async {
    List<LatLng> loc = [];

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        List<Map<String, LatLng>> things = [];

        if (locations != null) {
          for (var element in locations) {
            things.add(
                {DateTime.now().millisecondsSinceEpoch.toString(): element});
          }
        }

        return NewMapView(
          afterwards: null,
          singleLocation: false,
          locations: things,
          selectable: selectable,
        );
      }),
    ).then((value) {
      if (value != null) {
        loc = value;
      }
    });

    return loc;
  }

  Future<LatLng> pickLocation(BuildContext context,
      {bool selectable, List<LatLng> locations}) async {
    List<LatLng> loc = [];

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        List<Map<String, LatLng>> things = [];

        if (locations != null) {
          for (var element in locations) {
            things.add(
                {DateTime.now().millisecondsSinceEpoch.toString(): element});
          }
        }

        return NewMapView(
          afterwards: null,
          locations: things,
          selectable: selectable,
          singleLocation: true,
        );
      }),
    ).then((value) {
      loc = value;
    });

    return loc != null && loc.isNotEmpty ? loc[0] : null;
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    await StorageServices().launchTheThing(googleUrl);
  }

  Future<Map<String, dynamic>> getAddressFromLatLng(
    LatLng currentPosition,
  ) async {
    String textToReturn;
    Map<String, dynamic> ret = {};

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      Placemark place = placemarks[0];
      textToReturn =
          "${place.locality}, ${place.postalCode}, ${place.country}, ${place.street}";

      ret.addAll({
        "text": textToReturn,
        "pla": place,
      });
    } catch (e) {
      textToReturn = null;

      ret = null;
    }

    return ret;
  }

  Future<LatLng> getUserLocation(
    BuildContext context,
  ) async {
    if (await getLocation(context)) {
      return await Geolocator.getCurrentPosition().then((value) {
        return LatLng(
          value.latitude,
          value.longitude,
        );
      });
    } else {
      return null;
    }
  }

  Future<bool> getLocation(BuildContext context) async {
    return await _determinePosition().then(
      (value) {
        if (value.entries.first.key ==
            LocationFeedback.locationPermissionGranted) {
          return true;
        } else {
          showDialog(
              context: context,
              builder: (builder) {
                return CustomDialogBox(
                  bodyText: null,
                  buttonText: null,
                  onButtonTap: null,
                  showOtherButton: false,
                  child: Column(
                    children: [
                      Text(
                        value.entries.first.value["message"],
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                if (value.entries.first.key ==
                                    LocationFeedback
                                        .locationPermissionDeniedForever) {
                                  Navigator.of(context).pop();
                                  await Geolocator.openAppSettings();
                                } else {
                                  if (value.entries.first.key ==
                                      LocationFeedback.locationIsOff) {
                                    Navigator.of(context).pop();
                                    await Geolocator.openLocationSettings();
                                  } else {
                                    Navigator.of(context).pop();
                                    getLocation(context);
                                  }
                                }
                              },
                              child: Text(
                                value.entries.first.key ==
                                            LocationFeedback
                                                .locationPermissionDeniedForever ||
                                        value.entries.first.key ==
                                            LocationFeedback.locationIsOff
                                    ? "Settings"
                                    : "Try Again",
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Done",
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              });

          return false;
        }
      },
    );
  }

  Future<Map<LocationFeedback, Map<String, dynamic>>>
      _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        LocationFeedback.locationIsOff: {
          "message":
              'Location services are disabled. Please click here and turn on your location and try again'
        }
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return {
        LocationFeedback.locationPermissionDeniedForever: {
          "message":
              'Location permissions are permantly denied, we cannot find your current location. Please tap the button below, then Permissions and then grant location permissions.\n\nIf You completely fail, feel free to check FAQs for assistance'
        }
      };
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return {
          LocationFeedback.locationPermissionDenied: {
            "message":
                'Location permissions have been denied. Please grant the needed permissions in order to proceed.'
          }
        };
      }
    }

    return await Geolocator.getCurrentPosition().then((value) {
      return {
        LocationFeedback.locationPermissionGranted: {
          "message": 'Success',
          "location": value,
        }
      };
    });
  }
}

enum LocationFeedback {
  locationIsOff,
  locationPermissionDeniedForever,
  locationPermissionDenied,
  locationPermissionGranted,
}

class PlaceSearch {
  final String description;
  final String placeId;

  PlaceSearch({this.description, this.placeId});

  factory PlaceSearch.fromJson(Map<String, dynamic> json) {
    return PlaceSearch(
        description: json['description'], placeId: json['place_id']);
  }
}

class PlacesService {
  final key = googleMapsKey;

  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<Place> getPlace(String placeId) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;
    return Place.fromJson(jsonResult);
  }

  Future<List<Place>> getPlaces(
      double lat, double lng, String placeType) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?location=$lat,$lng&type=$placeType&rankby=distance&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['results'] as List;
    return jsonResults.map((place) => Place.fromJson(place)).toList();
  }
}

class Place {
  final Geometry geometry;
  final String name;
  final String vicinity;

  Place({this.geometry, this.name, this.vicinity});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      geometry: Geometry.fromJson(json['geometry']),
      name: json['formatted_address'],
      vicinity: json['vicinity'],
    );
  }
}

class Geometry {
  final Location location;

  Geometry({this.location});

  Geometry.fromJson(Map<dynamic, dynamic> parsedJson)
      : location = Location.fromJson(parsedJson['location']);
}

class Location {
  final double lat;
  final double lng;

  Location({this.lat, this.lng});

  factory Location.fromJson(Map<dynamic, dynamic> parsedJson) {
    return Location(lat: parsedJson['lat'], lng: parsedJson['lng']);
  }
}
