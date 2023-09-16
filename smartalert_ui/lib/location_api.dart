import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Post {
  final Map<String, dynamic>? json;

  Post({this.json});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(json: json);
  }
}

class LocationApi {
  final String locationBaseURI = '';

  Future<Post> _getProtocol(double latitude, double longitude) async {
    final Map<String, String> queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };

    final Uri uri =
        Uri.parse(locationBaseURI).replace(queryParameters: queryParams);

    final response = await http.get(uri); // pass in lat and lon

    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }
}
