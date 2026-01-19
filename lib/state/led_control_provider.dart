// lib/state/led_control_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pad.dart';
import '../models/pad_config.dart';
import '../services/led_control_service.dart';
import 'pads_provider.dart';
import 'pads_config_provider.dart';

/// État du contrôle LED
class LedControlState {
  final List<int> currentColors; // [color_A, color_B, color_C, color_D]
  final String? lastCommandSent; // Dernier message envoyé (pour log)
  final DateTime? lastSentTime; // Timestamp du dernier envoi

  const LedControlState({
    required this.currentColors,
    this.lastCommandSent,
    this.lastSentTime,
  });

  LedControlState copyWith({
    List<int>? currentColors,
    String? lastCommandSent,
    DateTime? lastSentTime,
  }) {
    return LedControlState(
      currentColors: currentColors ?? this.currentColors,
      lastCommandSent: lastCommandSent ?? this.lastCommandSent,
      lastSentTime: lastSentTime ?? this.lastSentTime,
    );
  }
}

/// Notifier pour gérer l'état du contrôle LED
class LedControlNotifier extends StateNotifier<LedControlState> {
  final StateNotifierProviderRef<LedControlNotifier, LedControlState> ref;

  LedControlNotifier(this.ref)
    : super(
        const LedControlState(
          currentColors: [1, 1, 1, 1], // Par défaut tous blanc
        ),
      ) {
    // Initialiser en écoutant les changements de poids/config
    _initializeListener();
  }

  void _initializeListener() {
    // Cette méthode sera appelée automatiquement par le watch dans le provider
  }

  /// Met à jour les couleurs LED et détecte les changements
  /// Retourne true si couleurs ont changé
  bool updateColors(Map<Pad, int> weights, Map<Pad, PadConfig> configs) {
    final newColors = LedControlService.getAllColors(weights, configs);

    if (LedControlService.colorsChanged(state.currentColors, newColors)) {
      final command = LedControlService.formatLedCommand(newColors);

      state = state.copyWith(
        currentColors: newColors,
        lastCommandSent: command,
        lastSentTime: DateTime.now(),
      );

      return true;
    }

    return false;
  }

  /// Obtient le message LED formaté pour l'ESP32
  String getLedCommand() =>
      LedControlService.formatLedCommand(state.currentColors);

  /// Réinitialise l'état
  void reset() {
    state = const LedControlState(currentColors: [1, 1, 1, 1]);
  }
}

/// Provider pour le contrôle LED
/// Watch automatiquement les pads et configs pour synchroniser les couleurs
final ledControlProvider =
    StateNotifierProvider<LedControlNotifier, LedControlState>((ref) {
      final notifier = LedControlNotifier(ref);

      // Watch les poids et configs pour déterminer les couleurs
      ref.listen(padsProvider, (previous, next) {
        final configs = ref.read(padsConfigProvider);
        notifier.updateColors(next, configs);
      });

      // Watch aussi les configs en cas de changement de seuils
      ref.listen(padsConfigProvider, (previous, next) {
        final weights = ref.read(padsProvider);
        notifier.updateColors(weights, next);
      });

      return notifier;
    });
