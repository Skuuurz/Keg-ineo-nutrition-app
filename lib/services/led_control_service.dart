// lib/services/led_control_service.dart
import '../models/pad.dart';
import '../models/pad_config.dart';

/// Couleurs LED simples (0-5)
class LedColor {
  static const int off = 0; // LED éteinte
  static const int white = 1; // Blanc (pas d'aliment ou taré)
  static const int blinkingBlue = 2; // Bleu clignotant (réservé)
  static const int red = 3; // Rouge (poids < seuilBas)
  static const int orange = 4; // Orange (poids < seuilMoyen)
  static const int green = 5; // Vert (poids <= seuilHaut)
}

/// Service de détermination des couleurs LED basé sur les poids et seuils
class LedControlService {
  /// Détermine la couleur LED pour un pad donné
  ///
  /// Logique:
  /// - Pas d'aliment (name vide) ou poids == 0 → blanc (1)
  /// - Poids < seuilBas → rouge (3)
  /// - Poids < seuilMoyen → orange (4)
  /// - Poids <= seuilHaut → vert (5)
  /// - Poids > seuilHaut → off (0)
  static int getColorForPad(Pad pad, int weightGrams, PadConfig config) {
    // Pas d'aliment configuré ou poids 0 → blanc
    if (config.name.trim().isEmpty || weightGrams == 0) {
      return LedColor.white;
    }

    // Déterminer la couleur selon les seuils
    if (weightGrams < config.seuilBas) {
      return LedColor.red;
    } else if (weightGrams < config.seuilMoyen) {
      return LedColor.orange;
    } else if (weightGrams <= config.seuilHaut) {
      return LedColor.green;
    } else {
      // Poids dépasse le seuil haut → off
      return LedColor.off;
    }
  }

  /// Calcule les couleurs pour tous les pads
  /// Retourne une liste [color_A, color_B, color_C, color_D]
  static List<int> getAllColors(
    Map<Pad, int> weights,
    Map<Pad, PadConfig> configs,
  ) {
    final colors = <int>[];

    for (final pad in Pad.values) {
      final weight = weights[pad] ?? 0;
      final config = configs[pad] ?? const PadConfig();
      final color = getColorForPad(pad, weight, config);
      colors.add(color);
    }

    return colors;
  }

  /// Formate le message LED pour l'ESP32
  /// Format: "LED,color_A,color_B,color_C,color_D"
  static String formatLedCommand(List<int> colors) {
    if (colors.length != 4) {
      throw ArgumentError('Expected 4 colors, got ${colors.length}');
    }
    return 'LED,${colors[0]},${colors[1]},${colors[2]},${colors[3]}';
  }

  /// Vérifie si les couleurs ont changé (pour éviter le spam BLE)
  static bool colorsChanged(List<int> previousColors, List<int> currentColors) {
    if (previousColors.length != currentColors.length) {
      return true;
    }

    for (int i = 0; i < previousColors.length; i++) {
      if (previousColors[i] != currentColors[i]) {
        return true;
      }
    }

    return false;
  }
}
