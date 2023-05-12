import 'package:flutter/material.dart';

class Statistic {
  static const DIRECTORY = "statistics";

  String _key;
  String _name;
  Function _onTap;
  IconData _icon;
  bool _dontShowCount;
  Function _onButtonTap;
  String _buttonText;
  Color _color;

  String get name => _name;
  String get key => _key;
  Function get onTap => _onTap;
  IconData get icon => _icon;
  bool get dontShowCount => _dontShowCount;
  Color get color => _color;
  String get buttonText => _buttonText;
  Function get onButtonTap => _onButtonTap;

  Statistic.fromData(
    String name,
    String key,
    Function onTap,
    IconData icon,
    Color color, {
    String buttonText,
    Function onButtonTap,
    bool dontShowCount,
  }) {
    _name = name;
    _icon = icon;
    _color = color;
    _onTap = onTap;
    _key = key;
    _onButtonTap = onButtonTap;
    _dontShowCount = dontShowCount;
    _buttonText = buttonText;
  }
}
