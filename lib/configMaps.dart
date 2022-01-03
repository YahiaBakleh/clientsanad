import 'package:clientsanad/Assistants/colorAssistant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Models/allUsers.dart';

String mapKey = "AIzaSyAXhk1498g3ORPHcP6Wytkouh0Mn28obVo";
MaterialColor mainColor = ColorAssistant.toMatrialColor(41, 109, 134, '#296d86');
Color mainBlue = ColorAssistant.formHex('#296d86');

String  BrandBold='Brand Bold' ;
String  BrandRegular='Brand-Regular' ;
String  Signatra='Signatra';

User? firebaseUser;

Users? userCurrentInfo;

int? driverRequestTimeOut = 40;
String? statusRide = "";
String? rideStatus = "Driver is Coming";
String? carDetailsDriver = "";
String? driverName = "";
String? driverphone = "";

double? starCounter=0.0;
String? title="";
String? carRideType="";

String? serverToken = "key=AAAAB-NSOzo:APA91bF9niY__G_2VK_j_GqSBqPO1hYiD71oFPVz4PA21rnxEK5I9HH5Xs4ZlDfdEgN-rha7sS5p5GXvsVIT0-Ga8v3yHhX09w0LD21V4hIPS347d67LOdDt0SOyclSA2UnOsbLv7v5C";