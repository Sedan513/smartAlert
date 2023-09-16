import 'package:flutter/material.dart';
import 'package:location/location.dart';

const startAlignment = Alignment.bottomLeft;
const endAlignment = Alignment.topRight;

class ButtonPage extends StatefulWidget {
  const ButtonPage(this.color1, this.color2, {Key? key}) : super(key: key);

  final Color color1;
  final Color color2;

  @override
  _ButtonPageState createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  bool buttonPressed = false;
  LocationData? _locationData; // Store the location data here

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Call the function when the widget is initialized
  }

  void updateui() {
    setState(() {
      buttonPressed = !buttonPressed;
    });
  }

  void _getCurrentLocation() async {
    Location location = new Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final locationData = await location.getLocation();

    setState(() {
      _locationData = locationData; // Update the location data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.color1, widget.color2],
          begin: startAlignment,
          end: endAlignment,
        ),
      ),
      child: Center(
        child: buttonPressed
            ? const Text(
                //Put trevor's file here
                'Owner-generated prompt goes here',
                style: TextStyle(color: Colors.white),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_locationData != null)
                    Text(
                      'Latitude: ${_locationData!.latitude}, Longitude: ${_locationData!.longitude}',
                      style: TextStyle(color: Colors.white),
                    ),
                  TextButton(
                    onPressed: updateui,
                    child: Image.asset(
                      'assets/button_image.png',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
