import 'package:flutter/material.dart';

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
  void updateui() {
    setState(() {
      buttonPressed = !buttonPressed;
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
                'Owner generated prompt goes here',
                style: TextStyle(color: Colors.white),
              )
            : TextButton(
                onPressed:
                    updateui, // You should replace this with the actual onPressed function.
                child: Image.asset(
                  'assets/button_image.png',
                ),
              ),
      ),
    );
  }
}
