import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _location = Location();
  final Set<Marker> _markers = {};
  final List<LatLng> _polylineCoordinates = [];
  late Polyline _polyline;

  @override
  void initState() {
    super.initState();
    _location.onLocationChanged.listen((LocationData currentLocation) {
      updateMarkerAndCircle(currentLocation);
      updatePolyline(currentLocation);
    });

    Timer.periodic(const Duration(seconds: 10), (timer) {
      _getLocation();
    });
  }

  Future<void> _getLocation() async {
    try {
      var location = await _location.getLocation();
      updateMarkerAndCircle(location);
      updatePolyline(location);
    } catch (e) {
      print("Error: $e");
    }
  }

  void updateMarkerAndCircle(LocationData locationData) {
    LatLng latLng = LatLng(locationData.latitude!, locationData.longitude!);

    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId("myLocation"),
        position: latLng,
        onTap: () {
          _showInfoWindow(locationData);
        },
      ),
    );

    _controller.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 15),
      );
    });
  }

  void updatePolyline(LocationData locationData) {
    LatLng latLng = LatLng(locationData.latitude!, locationData.longitude!);

    _polylineCoordinates.add(latLng);
    _polyline = Polyline(
      polylineId: const PolylineId("poly"),
      color: Colors.blue,
      points: _polylineCoordinates,
      width: 5,
    );
  }

  void _showInfoWindow(LocationData locationData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("My current location"),
          content: Text(
              "Latitude: ${locationData.latitude}\nLongitude: ${locationData.longitude}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Map App"),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 15,
        ),
        markers: _markers,
        polylines: Set<Polyline>.from([_polyline]),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
