
import 'dart:math';

import 'package:clientsanad/Models/nearbyAvailableSpecialists.dart';

class GeoFireAssistant{
  static List<NearbyAvailableSpecialists> nearByAvailableSpecialistList = [];

  static void removeSpecialistFromList(String key){
    int index= nearByAvailableSpecialistList.indexWhere((element) => element.key ==key);
    nearByAvailableSpecialistList.removeAt(index);
  }
  static void updateSpecialistNearbyLocation(NearbyAvailableSpecialists specialist){
    int index= nearByAvailableSpecialistList.indexWhere((element) => element.key ==specialist.key);
    nearByAvailableSpecialistList[index].latitude= specialist.latitude;
    nearByAvailableSpecialistList[index].longitude= specialist.longitude;
  }

}