class OnBoardingItem {
  String _title;
  String _bigger;
  String _desc;
  String _pic;
  bool _svg;

  String get pic => _pic;
  String get bigger => _bigger;
  String get desc => _desc;
  String get title => _title;
  bool get svg => _svg;

  OnBoardingItem(
    this._title,
    this._bigger,
    this._desc,
    this._pic,
    this._svg,
  );
}
