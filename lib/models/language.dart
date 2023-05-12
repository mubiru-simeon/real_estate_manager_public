import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;

  Language(this.id, this.flag, this.name, this.languageCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, "🇺🇸", "English", ENGLISH),
      Language(2, "🇺🇬", "Luganda", LUGANDA),
    ];
  }
}

const String LAGUAGE_CODE = 'languageCode';

//languages code
const String ENGLISH = 'en';
const String LUGANDA = 'ga';

Future<Locale> saveLocaleToPrefs(String languageCode, Box box) async {
  box.put(
    LAGUAGE_CODE,
    languageCode,
  );

  return _locale(languageCode);
}

Future<Locale> getSavedLocaleFromPrefs(Box box) async {
  String languageCode = box.get(LAGUAGE_CODE) ?? ENGLISH;
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return const Locale(ENGLISH, '');
    case LUGANDA:
      return const Locale(LUGANDA, "");
    default:
      return const Locale(ENGLISH, '');
  }
}

AppLocalizations translation(BuildContext context) {
  return AppLocalizations.of(context);
}
