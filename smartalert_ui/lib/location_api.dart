import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const locationApi = '';

class Post {
  final int number;

  Post({this.number,this.people});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      number: json['number'],
    );
  }
}

Future<Post> fetchPost() async {
  final response = await http.get(locationApi);

  if (response.statusCode == 200) {
    return Post.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}