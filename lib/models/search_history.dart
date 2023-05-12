import 'package:dorx/services/sq_lite_services.dart';

class SearchHistory {
  String _text;
  int _time;
  String _id;

  String get text => _text;
  String get id => _id;
  int get time => _time;

  SearchHistory.fromMap(Map mp) {
    _text = mp[SearchHistoryDBServices.SEARCHHISTORYTEXT];
    _time = mp[SearchHistoryDBServices.TIMESEARCHED];
    _id = _time.toString();
  }

  toMap() {
    return {
      SearchHistoryDBServices.SEARCHHISTORYTEXT: _text,
      SearchHistoryDBServices.TIMESEARCHED: _time,
    };
  }
}
