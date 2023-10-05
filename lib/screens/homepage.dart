import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;

class Homepage extends StatefulWidget {
  final String title;
  Homepage({Key? key, required this.title}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? userLocation = " ";
  PermissionStatus? status;

  @override
  void initState()  {
    super.initState();
    getLocationPermission();
    getLocationInfoAndSetState();
  }

  void enableLocation(){
    getLocationPermission();
    getLocationInfoAndSetState();
  }

  Future<bool> getLocationPermission() async {
    status = await Permission.location.request();

    if (status!.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> getLocationInfoAndSetState() async {
    final location = loc.Location();
    final GeolocatorPlatform geolocator = GeolocatorPlatform.instance;

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          setState(() {
            userLocation = "Location service is disabled";
          });
          return;
        }
      }

      loc.LocationData locationData = await location.getLocation();
      double? latitude = locationData.latitude;
      double? longitude = locationData.longitude;

      if (latitude != null && longitude != null) {
        geocoding.Placemark? placemark =
            await getLocationInfo(latitude, longitude);
        if (placemark != null) {
          setState(() {
            userLocation = "${placemark.country}, ${placemark.locality}";
          });
        } else {
          setState(() {
            userLocation = "Location not found";
          });
        }
      } else {
        setState(() {
          userLocation = "Can't get location info";
        });
      }
    } catch (e) {
      setState(() {
        userLocation = "Error: $e";
      });
    }
  }

  Future<geocoding.Placemark?> getLocationInfo(
      double latitude, double longitude) async {
    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        geocoding.Placemark placemark = placemarks[0];
        return placemark;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            status != null && !status!.isGranted ? TextButton(
              onPressed: getLocationPermission,
              child: const Text("Access GPS"),
            ) : const Text(""),
            Container(
              height: 200,
              width: MediaQuery.of(context).size.width,
              color: Color.fromARGB(115, 45, 43, 49),
              child: Center(
                child: Text("Location is at: $userLocation"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
