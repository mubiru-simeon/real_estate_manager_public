class DorxSettings {
  static const DORXBOXNAME = "dorxBox";

  static const SEARCHHISTORY = "searchHistory";

  static const AUTOADDNUMBERS = "autoAddNumbers";
  static const SETTINGSMAP = "settingsMap";
  static const AUTOAPPROVEBOOKINGS = "autoApproveBookings";
  static const EMAILNOTIFICATIONS = "emailNotifications";

  bool _autoApproveBookings;
  bool _autoAddNumbers;
  bool _emailNotifications;

  bool get autoApproveBookings => _autoApproveBookings ?? false;
  bool get autoAddNumbers => _autoAddNumbers ?? false;
  bool get emailNotifications => _emailNotifications ?? true;

  DorxSettings.fromMap(dynamic propertyMap, dynamic userMap) {
    if (propertyMap != null) {
      _autoApproveBookings = propertyMap[AUTOAPPROVEBOOKINGS] ?? false;
      _autoAddNumbers = propertyMap[AUTOADDNUMBERS] ?? false;
    }

    if (userMap != null) {
      _emailNotifications = userMap[EMAILNOTIFICATIONS] ?? false;
    }
  }
}

Map getSettingsMap(DorxSettings settings) {
  Map pp = {};

  pp.addAll({
    DorxSettings.AUTOADDNUMBERS: settings.autoAddNumbers,
    DorxSettings.AUTOAPPROVEBOOKINGS: settings.autoApproveBookings,
  });

  return pp;
}
