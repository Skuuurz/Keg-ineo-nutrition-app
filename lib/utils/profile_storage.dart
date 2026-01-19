import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';

class ProfileStorage {
  static const _profilesKey = 'user_profiles';
  static const _currentIdKey = 'current_profile_id';

  static Future<List<Profile>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_profilesKey);
    if (str == null) return [];
    final list = (jsonDecode(str) as List<dynamic>)
        .map((e) => Profile.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  static Future<void> saveAll(List<Profile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _profilesKey,
      jsonEncode(profiles.map((p) => p.toJson()).toList()),
    );
  }

  static Future<String?> loadCurrentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentIdKey);
  }

  static Future<void> saveCurrentId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_currentIdKey);
    } else {
      await prefs.setString(_currentIdKey, id);
    }
  }
}
