import 'package:clientsanad/Models/address.dart';
import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier {
  Address? pickUpLocation, sessionLocation;

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateSessionLocationAddress(Address sessionAddress) {
    sessionLocation = sessionAddress;
    notifyListeners();
  }
}
