import 'package:clientsanad/AllScreens/MainScreen.dart';
import 'package:clientsanad/AllScreens/RegisterationScreen.dart';
import 'package:clientsanad/AllWidgets/progressDialog.dart';
import 'package:clientsanad/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:clientsanad/configMaps.dart';

class LoginScreen extends StatefulWidget {
  static const idScreen = 'login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 35.0,
                ),
                Image(image: AssetImage('images/Sanad-Logo.png'), height: 150.0, width: 390.0, alignment: Alignment.center),
                SizedBox(
                  height: 30.0,
                ),
                Text('Login as a Client', style: TextStyle(fontSize: 26, fontFamily: "Brand Bold"), textAlign: TextAlign.center),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 1.0,
                      ),

                      //Email Filed

                      TextFormField(
                        controller: email,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Email';
                          }
                          if (!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(value)) {
                            return 'Please enter valid Email';
                          }
                          return null;
                        },
                        maxLength: 50,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            errorStyle: TextStyle(fontFamily: 'Brand Regular', fontSize: 16, color: Colors.redAccent),
                            contentPadding: EdgeInsets.all(2.0), //  <- you can it to 0.0 for no space
                            isDense: true,
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 22)),
                        style: TextStyle(fontSize: 22.0, fontFamily: 'Brand Bold'), //Email field style
                      ), //End Email Filed

                      SizedBox(
                        height: 30.0,
                      ),

                      //Password Filed

                      TextFormField(
                        controller: password,
                        obscureText: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Password';
                          }
                          return value.length <= 6 ? 'Password is equal or greater than 7 characters' : null;
                        },
                        decoration: InputDecoration(
                            errorStyle: TextStyle(fontFamily: 'Brand Regular', fontSize: 16, color: Colors.redAccent),
                            contentPadding: EdgeInsets.all(2.0), //  <- you can it to 0.0 for no space
                            isDense: true,
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 22)),
                        style: TextStyle(fontSize: 22.0, fontFamily: 'Brand Bold'),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),

                      //Login Button

                      RaisedButton(
                        // color: Colors.indigo,
                        color: mainBlue,
                        textColor: Colors.white,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Processing Data')),
                            );
                            //TODO: if user not login by going to main screen  put 'logInUser(context);' out of if {...}
                            logInUser(context);
                          }
                        },
                        child: Container(
                          height: 50.0,
                          child: Center(
                            child: Text(
                              'Login',
                              style: TextStyle(fontSize: 22.0, fontFamily: 'Brand Bold'),
                            ),
                          ),
                        ),
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(25.0)),
                      ),
                    ],
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, RegisterationScreen.idScreen, (route) => false);
                    },
                    child: Text(
                      'Do Not Have an Account? Register Here.',
                      style: TextStyle(fontSize: 16.0, fontFamily: 'Brand Bold', color: Colors.black),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void logInUser(BuildContext contx) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(message: "Log in , Please Wait...");
        });
    
    final User? result = (await _firebaseAuth.signInWithEmailAndPassword(email: email.text, password: password.text).catchError((error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Error: ' + error.toString());
    }))
        .user;
    if (result != null) {
      usersRef.child(result.uid).once().then((DataSnapshot snap) {
        if (snap.value != null) {
          Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
          Fluttertoast.showToast(msg: "You Logged in");
        } else {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          Fluttertoast.showToast(msg: "No Such User. Please create new account");
        }
      });
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error, Can not be  sing in");
    }
  }
}
