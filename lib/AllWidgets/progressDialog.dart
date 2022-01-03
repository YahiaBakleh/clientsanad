import 'package:flutter/material.dart';
import 'package:clientsanad/configMaps.dart';

class ProgressDialog extends StatelessWidget {
  final String? message;
  const ProgressDialog({this.message, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // backgroundColor: Colors.indigo,
      backgroundColor: mainBlue,
      child: Container(
        margin: EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              SizedBox(
                width: 6.0,
              ),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
              SizedBox(
                width: 26.0,
              ),
              Text(message.toString(), style: TextStyle(color: Colors.black, fontSize: 10.0, fontFamily: 'Brand Bold')),
            ],
          ),
        ),
      ),
    );
  }
}
