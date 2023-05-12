import 'package:dorx/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';

import '../main.dart';
import '../models/models.dart';

class LanguageChangerWidget extends StatefulWidget {
  final Color widgetColor;
  final Widget child;
  const LanguageChangerWidget({
    Key key,
    this.widgetColor = Colors.grey,
    this.child,
  }) : super(key: key);

  @override
  State<LanguageChangerWidget> createState() => _LanguageChangerWidgetState();
}

class _LanguageChangerWidgetState extends State<LanguageChangerWidget> {
  Box box;

  @override
  void initState() {
    super.initState();

    box = Hive.box(DorxSettings.DORXBOXNAME);
  }

  @override
  Widget build(BuildContext context) {
    return FocusedMenuHolder(
      openWithTap: true,
      animateMenuItems: true,
      onPressed: () {},
      menuItems: Language.languageList()
          .map<FocusedMenuItem>(
            (e) => FocusedMenuItem(
              backgroundColor: primaryColor,
              title: Row(
                children: [
                  Text(
                    e.flag,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    e.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              onPressed: () async {
                Locale locale = await saveLocaleToPrefs(
                  e.languageCode,
                  box,
                );

                MyApp.setLocale(context, locale);
              },
            ),
          )
          .toList(),
      child: widget.child ??
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  FontAwesomeIcons.language,
                  color: widget.widgetColor ?? Colors.white,
                ),
              ),
            ],
          ),
    );
  }
}
