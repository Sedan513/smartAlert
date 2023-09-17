import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:smartalert_ui/location_api.dart';
import 'package:smartalert_ui/protocol_display.dart';

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
  List<dynamic>? protocolJson; // Store the json data here
  Map<String, List<dynamic>> emergencyIncidents = {
    'Medical': [0, 'assets/medical_button.png'],
    'Security': [1, 'assets/security_button.png'],
    'Fire': [2, 'assets/fire_button.png'],
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Call the function when the widget is initialized
    _getProtocol(); // Call the function when the widget is initialized
  }

  void updateui() {
    setState(() {
      buttonPressed = !buttonPressed;
    });
  }

  Future<LocationData?> _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    final locationData = await location.getLocation();

    setState(() {
      _locationData = locationData; // Update the location data
    });
    return locationData;
  }

  void _getProtocol() async {
    LocationData? loc = await _getCurrentLocation();

    if (loc == null) {
      throw "location could not be found";
    }

    protocolJson =
        await LocationApi.requestProtocol(loc.latitude!, loc.longitude!);
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
            ? ProtocolScreen(infoMap: protocolJson!)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_locationData != null)
                    TextButton(
                      onPressed: updateui,
                      child: Image.asset(
                        emergencyIncidents['Medical']![1],
                      ),
                    ),
                  TextButton(
                    onPressed: updateui,
                    child: Image.asset(
                      emergencyIncidents['Security']![1],
                    ),
                  ),
                  TextButton(
                    onPressed: updateui,
                    child: Image.asset(
                      emergencyIncidents['Fire']![1],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
