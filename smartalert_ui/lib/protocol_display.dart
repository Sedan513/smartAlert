import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProtocolScreen extends StatefulWidget {
  final List<dynamic> infoMap;

  const ProtocolScreen({super.key, required this.infoMap});

  @override
  _ProtocolScreenState createState() => _ProtocolScreenState();
}

class _ProtocolScreenState extends State<ProtocolScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.infoMap[0]['title']}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0), // Add spacing at the top
          child: ListView.builder(
            itemCount: widget.infoMap[0]['protocol'].length,
            itemBuilder: (context, index) {
              Map<String, dynamic> item = widget.infoMap[0]['protocol'][index];
              if (item.keys.first == 'phone') {
                print("\n\n\n phone: ${item.values.first}");
                return ProtocolCallButton(phone: item.values.first.toString());
              } else {
                //if (item.keys.first == 'message') {
                print("\n\n\n message: ${item.values.first}");
                return ProtocolInstruction(
                    message: item.values.first.toString());
              }
            },
          ),
        ),
      ),
    );
  }
}

class ProtocolCallButton extends StatelessWidget {
  final String phone; // Add a parameter for the phone number.

  const ProtocolCallButton({super.key, required this.phone});

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
      child: ListTile(
        title: Text(
          'Dial $phone',
          style: const TextStyle(
            fontSize: 18, // Adjust the font size as needed
            fontFamily: 'Verdana', // Replace with your desired font family
            fontWeight: FontWeight.normal, // Adjust font weight as needed
            color: Colors.blue, // Adjust text color as needed
          ),
        ),
        subtitle: const Text(
          'Tap to dial',
          style: TextStyle(
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
    );
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
        color: Colors.black, // Adjust text color as needed
      ),
      textAlign: TextAlign.left,
    );
  }
}
