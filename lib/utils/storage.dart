import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pad.dart';
import '../models/pad_config.dart';

/// Sauvegarde et chargement des configurations utilisateurs (noms, seuils, tare)
class PadStorage {
  static const _key = 'pads_config';

  /// Sauvegarde l’état complet sous forme JSON
  static Future<void> save(Map<Pad, PadConfig> configs) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      for (final p in Pad.values)
        p.name: {
          'name': configs[p]?.name ?? '',
          'seuilBas': configs[p]?.seuilBas ?? 50,
          'seuilMoyen': configs[p]?.seuilMoyen ?? 100,
          'seuilHaut': configs[p]?.seuilHaut ?? 150,
          'tared': configs[p]?.tared ?? true,
        },
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  /// Charge depuis SharedPreferences
  static Future<Map<Pad, PadConfig>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str == null) return {for (final p in Pad.values) p: const PadConfig()};

    final map = jsonDecode(str) as Map<String, dynamic>;
    return {
      for (final p in Pad.values)
        p: PadConfig(
          name: map[p.name]?['name'] ?? '',
          seuilBas: map[p.name]?['seuilBas'] ?? 50,
          seuilMoyen: map[p.name]?['seuilMoyen'] ?? 100,
          seuilHaut: map[p.name]?['seuilHaut'] ?? 150,
          tared: map[p.name]?['tared'] ?? true,
        ),
    };
  }

  /// Réinitialise la sauvegarde
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
