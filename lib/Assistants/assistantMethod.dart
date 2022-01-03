import 'dart:convert';
import 'dart:math';

import 'package:clientsanad/Assistants/requestAssistant.dart';
import 'package:clientsanad/DataHandler/appData.dart';
import 'package:clientsanad/Models/address.dart' as userAddress;
import 'package:clientsanad/Models/allUsers.dart';
import 'package:clientsanad/Models/directionDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:clientsanad/configMaps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AssistantMethod {
//TODO:  enable Billing on the Google Cloud Project at https://console.cloud.google.com/ Learn more at https://developers.google.com/maps/gmp-get-started"

  static Future<String> searchCoordinateAddress(Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    /**TODO: Add API_KEY**/
    // String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=" + position.altitude.toString() + "," + position.longitude.toString() + "&key=" + mapKey.toString();
    // Uri url =Uri.parse(("https://maps.googleapis.com/maps/api/geocode/json?latlng=" + position.altitude.toString() + "," + position.longitude.toString() + "&key=" + mapKey.toString()).trim());
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.altitude},${position.longitude}&key=$mapKey";
    print(url);
    var response = await RequestAssistant.getRequest(url);
    if (response != 'failed') {
      // placeAddress = response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][3]["long_name"].toString();
      st2 = response["results"][0]["address_components"][4]["long_name"].toString();
      st3 = response["results"][0]["address_components"][5]["long_name"].toString();
      st4 = response["results"][0]["address_components"][6]["long_name"].toString();
      placeAddress = (st1 + " " + st2 + " " + st3 + " " + st4).toString();
      userAddress.Address userPickUpAddress = new userAddress.Address(placeName: placeAddress);
      print(placeAddress);
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }
    return placeAddress;
  }

  static Future<String?> getAddressByCoordinate(Position position, context) async {
    List<Placemark> address = await placemarkFromCoordinates(position.latitude, position.longitude);
    userAddress.Address userPickUpAddress = new userAddress.Address();
    // String addressLocation = address.first.locality.toString() + '1 , ' + address.first.street.toString() + '2 , ' + address.first.name.toString() + '3 , ';
    String addressLocation = address.first.street.toString() + ' , ';
    userPickUpAddress.latitude = position.latitude;
    userPickUpAddress.longitude = position.longitude;
    userPickUpAddress.placeName = addressLocation;
    Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    return address.first.name;
  }

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(LatLng initialPostion,LatLng finalPosition ) async {
    String directionUrl="https://maps.googleapis.com/maps/api/directions/json?origin=${initialPostion.latitude},${initialPostion.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";
    var res = await RequestAssistant.getRequest(directionUrl);
    if(res == "failed")
    {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails(encodedPoints: '');

    directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];
    directionDetails.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];
    directionDetails.durationText = res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue = res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails){
      return 10 ;
  }

  static void getCurrentOnlineUserInfo() async {
    firebaseUser = await FirebaseAuth.instance.currentUser;
    String userId = firebaseUser!.uid;
    DatabaseReference reference = FirebaseDatabase.instance.reference().child('userId');
    reference.once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null){
        userCurrentInfo = Users.fromSnapshot(dataSnapshot);
      }
    });
  }

  // to  create random number
  static double createRandomNumber(int num){
    var random = Random();
    return random.nextInt(num).toDouble();
  }

  static void sendNotification(String token,context,String user_request_id ) async{
    var session = Provider.of<AppData>(context,listen: false).sessionLocation;
    Map<String,String> headerMap = {
      'Content-Type':'application/json',
      'Authorization': serverToken.toString()
    };
    Map<String,String> notificationMap={
      'body':'Sesion Location ${session?.placeName}',
      'title':'New User Request'
    };
    Map dataMap ={
      'click_action':'FLUTTER_NOTIFICATION_CLICK',
      'id':'1',
      'status':'done',
      'user_request_id':user_request_id
    };
    Map sendNotification={
      'notification':notificationMap,
      'data':dataMap,
      'priority': 'high',
      'to':token
    };
    var res = await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"), headers:headerMap, body: jsonEncode(sendNotification));
  }
}

