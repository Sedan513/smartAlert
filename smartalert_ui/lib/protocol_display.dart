import 'package:flutter/material.dart';

class ProtocolScreen extends StatefulWidget {
  final Map<String, dynamic> infoMap;

  ProtocolScreen({required this.infoMap});

  @override
  _ProtocolScreenState createState() => _ProtocolScreenState();
}

class _ProtocolScreenState extends State<ProtocolScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.infoMap['title']}'),
      ),
      body: ListView.builder(
        itemCount: widget.infoMap['protocol'].length,
        itemBuilder: (context, index) {
          if (widget.infoMap['protocol'][index].key == 'message') {
            
          }
          final key = widget.infoMap.keys.toList()[index];
          final value = widget.infoMap[key];
          return ListTile(
            title: Text('$key: $value'),
            body:
          );
        },
      ),
    );
  }
}