import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class FavoritesStorage {
  static String _keyForProfile(String profileId) => 'favorites_' + profileId;

  static Future<List<Recipe>> loadForProfile(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyForProfile(profileId));
    if (str == null) return [];
    final data = jsonDecode(str) as List<dynamic>;
    return data.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> saveForProfile(
    String profileId,
    List<Recipe> favorites,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyForProfile(profileId),
      jsonEncode(favorites.map((r) => r.toJson()).toList()),
    );
  }
}
