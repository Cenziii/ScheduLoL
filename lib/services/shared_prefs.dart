import 'package:shared_preferences/shared_preferences.dart';
import 'package:lol_competitive/classes/match.dart';

class SharedPreferencesService{

  SharedPreferencesService._internal();
  static final SharedPreferencesService _instance = SharedPreferencesService._internal();
  factory SharedPreferencesService() => _instance;

  Future<List<String>?> getSharedPreferences(String id) async
  {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(id);
  }

  Future<void> setSharedPreferences(String key, List<String> vals) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, vals);
  }

  Future<void> addNotificationsPastMatch(Match match) async {
  final prefs = await SharedPreferences.getInstance();
  final ids = prefs.getStringList('notify_ids') ?? [];
  ids.add(match.id.toString());
  await prefs.setStringList('notify_ids', ids);
}

  Future<bool> checkNotification(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? ids = prefs.getStringList('notify_ids');
    if (ids != null) {
      bool result = ids.any((item) => int.parse(item) == id);
      return result;
    } else {
      return false;
    }
  }

  Future<void> checkNotificationsPastMatch(List<Match> match) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? ids = prefs.getStringList('notify_ids');
    if (ids != null) {
      for (int i = 0; i < match.length; i++) {
        if (match[i].id != null) {
          ids.any((id) => id == match[i].id.toString());
          ids.removeWhere((element) => element == match[i].id.toString());
        }
      }
      prefs.setStringList('notify_ids', ids);
    } else {
      List<String> ids = [];
      prefs.setStringList('notify_ids', ids);
    }
  }
}