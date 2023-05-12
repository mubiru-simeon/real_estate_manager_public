import 'package:flutter/material.dart';
import 'package:flutter_gradients/flutter_gradients.dart';
import 'basic.dart';

TextStyle titleStyle = TextStyle(
  fontSize: 16,
  color: primaryColor,
  fontWeight: FontWeight.bold,
);

TextStyle darkTitle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

TextStyle whiteTitle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
);

TextStyle greyTitle = TextStyle(
  fontSize: 16,
);

const standardElevation = 5.0;
const borderDouble = 8.0;
BorderRadius standardBorderRadius = BorderRadius.circular(borderDouble);

String sharedPrefBrightness = "${capitalizedAppName}_brightness";

String sharedPrefDoneWithAgeOnboarding = "${capitalizedAppName}_age_onboarding";
String sharedPrefDoneWithOnBoarding = "${capitalizedAppName}_onboarding";

getTabColor(
  BuildContext context,
  bool selected,
) {
  Color selectedColor = Colors.grey;
  Color notSelectedColor = selectedColor.withOpacity(0.5);

  return selected ? selectedColor : notSelectedColor;
}

const darkBgColor = Color(0xff121621);

const MaterialColor primaryColor = MaterialColor(
  0xffce9030,
  <int, Color>{
    50: Color(0xffce9030),
    100: Color(0xffce9030),
    200: Color(0xffce9030),
    300: Color(0xffce9030),
    400: Color(0xffce9030),
    500: Color(0xffce9030),
    600: Color(0xffce9030),
    700: Color(0xffce9030),
    800: Color(0xffce9030),
    900: Color(0xffce9030),
  },
);

const altColor = Colors.blue;

const List<LinearGradient> listColors = [
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.indigoAccent,
      Colors.teal,
    ],
  ),
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.purple,
      Colors.red,
    ],
  ),
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.green,
      Colors.blue,
    ],
  ),
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.orange,
      Colors.redAccent,
    ],
  ),
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.purple,
      Colors.blue,
    ],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xffCE9FFC),
      Color(0xff7367F0),
    ],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xffFFF6B7),
      Color(0xffF6416C),
    ],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff43CBFF),
      Color(0xff9708CC),
    ],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xffFCCF31),
      Color(0xffF55555),
    ],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff3B2667),
      Color(0xffBC78EC),
    ],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xffFAB2FF),
      Color(0xff1904E5),
    ],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff81FFEF),
      Color(0xffF067B4),
    ],
  ),
];

Map<String, Gradient> availableGradients = {
  "deep blue": FlutterGradients.deepBlue(
    tileMode: TileMode.clamp,
  ),
  "deep relief": FlutterGradients.deepRelief(
    tileMode: TileMode.clamp,
  ),
  "juicy cake": FlutterGradients.juicyCake(
    tileMode: TileMode.clamp,
  ),
  "juicy peach": FlutterGradients.juicyPeach(
    tileMode: TileMode.clamp,
  ),
  "lady lips": FlutterGradients.ladyLips(
    tileMode: TileMode.clamp,
  ),
  "frozen berry": FlutterGradients.frozenBerry(
    tileMode: TileMode.clamp,
  ),
  "orange juice": FlutterGradients.orangeJuice(
    tileMode: TileMode.clamp,
  ),
  "fresh milk": FlutterGradients.freshMilk(
    tileMode: TileMode.clamp,
  ),
  "fruit blend": FlutterGradients.fruitBlend(
    tileMode: TileMode.clamp,
  ),
  "space shift": FlutterGradients.spaceShift(
    tileMode: TileMode.clamp,
  ),
  "sunset": FlutterGradients.trueSunset(
    tileMode: TileMode.clamp,
  ),
  "alto": FlutterGradients.paloAlto(
    tileMode: TileMode.clamp,
  ),
  "simeon": FlutterGradients.itmeoBranding(
    tileMode: TileMode.clamp,
  ),
};
