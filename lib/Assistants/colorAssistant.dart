import 'package:flutter/material.dart';

class ColorAssistant {
  static Color formHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length <= 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static MaterialColor toMatrialColor(int R , int G, int B , String hexString){
    Map<int, Color> color =
    {
      50 :Color.fromRGBO(R,G,B, .1),
      100:Color.fromRGBO(R,G,B, .2),
      200:Color.fromRGBO(R,G,B, .3),
      300:Color.fromRGBO(R,G,B, .4),
      400:Color.fromRGBO(R,G,B, .5),
      500:Color.fromRGBO(R,G,B, .6),
      600:Color.fromRGBO(R,G,B, .7),
      700:Color.fromRGBO(R,G,B, .8),
      800:Color.fromRGBO(R,G,B, .9),
      900:Color.fromRGBO(R,G,B, 1),
    };
    final buffer = StringBuffer();
    if (hexString.length <= 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    var hexColor =int.parse(buffer.toString(), radix: 16);
    return MaterialColor(hexColor, color);

  }
}
