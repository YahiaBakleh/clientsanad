import 'package:clientsanad/AllScreens/LoginScreen.dart';
import 'package:clientsanad/AllScreens/MainScreen.dart';
import 'package:clientsanad/AllScreens/RegisterationScreen.dart';
import 'package:clientsanad/DataHandler/appData.dart';
import 'package:clientsanad/configMaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('users');
DatabaseReference specialistRef = FirebaseDatabase.instance.reference().child('specialists');

class MyApp extends StatelessWidget {
  static const idScreen = 'mainScreen';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Sanad - Every thing Start Small',
        theme: ThemeData(
          //primarySwatch: Colors.indigo,
          primarySwatch: mainColor,
          fontFamily: 'Brand Bold',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => FirebaseAuth.instance.currentUser==null?LoginScreen():MainScreen(), //LoginScreen(),
          // '/': (context) => const RegisterationScreen(), //LoginScreen(),
          RegisterationScreen.idScreen: (context) => RegisterationScreen(),
          LoginScreen.idScreen: (context) => LoginScreen(),
          MainScreen.idScreen: (context) => MainScreen()
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
