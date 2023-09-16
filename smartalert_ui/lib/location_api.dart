import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';


class Post {
  final Map<String, dynamic> json;

  Post({this.json});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post( json );
  }
}

class LocationApi {
  const locationBaseURI = '';
  
  LocationData? _currentLocation;

  Future<Post> _getProtocol(double latitude, double longitude) async {
    final Map<String, String> queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };

    final Uri uri = Uri.parse(locationBaseURI).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri); // pass in lat and lon

      if (response.statusCode == 200) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load post');

      }
    } catch (error) {
      print('Error: $error');
    }
  }

  /* GET LOCATION FROM PHONE */
  Future<LocationData> _getLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if location services are enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check if location permissions are granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    // Get the current location
    LocationData locationData = await location.getLocation();
    setState(() {
      _currentLocation = locationData;
    });
  }
}