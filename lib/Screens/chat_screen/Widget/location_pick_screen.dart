import 'dart:async';

import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickScreen extends StatefulWidget {
  Function(LatLng latLng) sendLocation;


  LocationPickScreen({required this.sendLocation});

  @override
  _LocationPickScreenState createState() => _LocationPickScreenState();
}

class _LocationPickScreenState extends State<LocationPickScreen> {
  late GoogleMapController _controller;
  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(0, 0),
    zoom: 14.4746,
  );
  LatLng _locationLatlng= LatLng(0, 0);
  List<Marker> _markers = <Marker>[];
  bool _isFullScreenMap = false;

  @override
  void initState() {
    super.initState();

    _markers.add(Marker(markerId: MarkerId('test'), position: LatLng(0, 0)));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: _isFullScreenMap ? size.height * 0.74 : size.height * 0.4,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    // markers: Set<Marker>.of(_markers),
                    initialCameraPosition: _kGooglePlex,
                    zoomControlsEnabled: false,
                    onTap: (LatLng? latlng) {
                      // if (latlng != null) {
                      //   _setCameraPosition(latLng: latlng);
                      // }
                    },
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                      _determinePosition();
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 45, left: 15),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        onTap: () {
                          _isFullScreenMap = !_isFullScreenMap;
                          setState(() {});
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            _isFullScreenMap
                                ? Icons.zoom_out_map
                                : Icons.zoom_out_map,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: (){
                Navigator.pop(context);
                widget.sendLocation(_locationLatlng);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.my_location,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Send your current location",style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                          ),),
                          Text("Accurate to 16 meters",style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14
                          ),)
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      Fiberchat.toast(
          'Location permissions are pdenied. Please go to settings & allow location tracking permission.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        Fiberchat.toast(
            'Location permissions are pdenied. Please go to settings & allow location tracking permission.');
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        Fiberchat.toast(
            'Location permissions are pdenied. Please go to settings & allow location tracking permission.');
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Fiberchat.toast(
        getTranslated(this.context, 'detectingloc'),
      );
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    _setCameraPosition(latLng: LatLng(position.latitude, position.longitude));
    return position;
  }

  void _setCameraPosition({required LatLng latLng}) {
    _locationLatlng = latLng;
    _markers.add(
      Marker(
        markerId: MarkerId('test'),
        position: latLng,
      ),
    );
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
          zoom: 14,
        ),
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }
}
