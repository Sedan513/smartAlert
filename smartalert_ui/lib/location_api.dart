import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocationApi {
  static const String locationBaseURI = '';

  static Future<List<dynamic>> requestProtocol(
      double latitude, double longitude) async {
    final Map<String, String> queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };

    // testing
    List<dynamic> jsonDecoded = jsonDecode(
        '[{"title":"Fire@Makerspace","protocol":[{"messages":["blah","ihatehophakcs"]},{"phone":["7325208969"]}]},{"title":"Flood@FastForwardU","protocol":[{"messages":["blah","ihatehophakcs"]},{"phone":["83323242342","fasdfasdf"]}]}]');

    print(jsonDecoded.length);
    print(jsonDecoded[0]);

    return jsonDecoded;
  }
}
    // final Uri uri =
    //     Uri.parse(locationBaseURI).replace(queryParameters: queryParams);

    // final response = await http.get(uri); // pass in lat and lon

    // if (response.statusCode == 200) {
    //   return json.decode(response.body);
    // } else {
    //   throw Exception('Failed to load post');
    // }
//   }
// }