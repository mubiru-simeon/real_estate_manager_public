import 'package:flutter/material.dart';
import 'package:dorx/constants/ui.dart';
import 'package:hive/hive.dart';
import '../models/settings.dart';

class ThemeBuilder extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    Brightness brightness,
  ) builder;

  ThemeBuilder({Key key, this.builder}) : super(key: key);

  @override
  State<ThemeBuilder> createState() => _ThemeBuilderState();

  // ignore: library_private_types_in_public_api
  static _ThemeBuilderState of(BuildContext context) {
    return context.findAncestorStateOfType<_ThemeBuilderState>();
  }
}

class _ThemeBuilderState extends State<ThemeBuilder> {
  Brightness _brightness = Brightness.dark;
  Box box;

  @override
  void initState() {
    super.initState();
    box = Hive.box(DorxSettings.DORXBOXNAME);
    getThemePref();
  }

  getThemePref() async {
    String bright = box.get(
          sharedPrefBrightness,
        ) ??
        'light';

    if (bright == "light") {
      _brightness = Brightness.light;
    } else {
      _brightness = Brightness.dark;
    }

    if (mounted) setState(() {});
  }

  void makeLight() {
    setState(() {
      _brightness = Brightness.light;
    });
  }

  void makeDark() {
    setState(() {
      _brightness = Brightness.dark;
    });
  }

  Brightness getCurrentTheme() {
    return _brightness;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _brightness);
  }
}
