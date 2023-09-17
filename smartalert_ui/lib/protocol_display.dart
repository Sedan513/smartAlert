import 'package:flutter/material.dart';
import 'package:smartalert_ui/location_api.dart';
import 'package:url_launcher/url_launcher.dart';

class ProtocolScreen extends StatefulWidget {
  final List<dynamic> infoMap;
  late int protocolID;

  ProtocolScreen({super.key, required this.infoMap}) {
    print("\n\n\n\n\n pocean eyes");
    protocolID = infoMap[0]['protocol_id'];
    LocationApi.sendButtonPressed(protocolID);
  }

  @override
  _ProtocolScreenState createState() => _ProtocolScreenState();
}

class _ProtocolScreenState extends State<ProtocolScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '${widget.infoMap[0]['name']}',
          style: const TextStyle(color: Colors.white, fontSize: 30),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.black),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0), // Add spacing at the top
            child: ListView.builder(
              itemCount: widget.infoMap[0]['message'].length +
                  widget.infoMap[0]['phone_number'].length,
              itemBuilder: (context, index) {
                Map<String, dynamic> protocol = widget.infoMap[0];
                if (index < protocol['message'].length) {
                  // is a message
                  return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 0.0),
                      child: ProtocolInstruction(
                          message: protocol['message'][index].toString()));
                } else {
                  // is a phone number
                  return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 0.0),
                      child: ProtocolCallButton(
                          contactName: protocol['phone_number_name']
                              [index - protocol['message'].length],
                          phone: protocol['phone_number']
                                  [index - protocol['message'].length]
                              .toString()));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ProtocolCallButton extends StatelessWidget {
  final String phone; // Add a parameter for the phone number.
  final String contactName;

  const ProtocolCallButton(
      {super.key, required this.phone, required this.contactName});

  _launchPhoneDialer() async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Add your button action here
          _launchPhoneDialer();
        },
        child: Align(
          alignment: Alignment.centerRight,
          child: ListTile(
            title: Text(
              contactName,
              style: const TextStyle(
                fontSize: 18, // Adjust the font size as needed
                fontFamily: 'Verdana', // Replace with your desired font family
                fontWeight: FontWeight.normal, // Adjust font weight as needed
                color: Colors.blue, // Adjust text color as needed
              ),
            ),
            subtitle: Text(
              phone,
              style: const TextStyle(
                fontSize: 14, // Adjust the font size as needed
                fontFamily: 'Verdana', // Replace with your desired font family
                fontWeight: FontWeight.normal, // Adjust font weight as needed
                color: Colors.grey, // Adjust text color as needed
              ),
            ),
            leading: const Icon(
              Icons.phone,
              color: Colors.blue, // Adjust icon color as needed
            ),
          ),
        ));
  }
}

class ProtocolInstruction extends StatelessWidget {
  final String message;

  const ProtocolInstruction({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 22, // Adjust the font size as needed
        fontFamily: 'Verdana', // Replace with your desired font family
        fontWeight: FontWeight.normal, // Adjust font weight as needed
        color: Colors.white, // Adjust text color as needed
      ),
      textAlign: TextAlign.center,
    );
  }
}
