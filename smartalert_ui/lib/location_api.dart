import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationApi {
  static const String locationBaseURI =
      'https://smartalert-919c8c8f9220.herokuapp.com/locations';

  static Future<List<dynamic>> requestProtocol(
      double latitude, double longitude) async {
    final Map<String, String> queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };

    final Uri uri = Uri.parse(locationBaseURI);

    final response = await http.post(
      uri,
      body: json.encode(queryParams), // Encode the parameters as JSON
      headers: {
        'Content-Type': 'application/json', // Set the content type to JSON
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('\n\n\n\n\n $data \n\n\n\n\n\n\n\n');
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
