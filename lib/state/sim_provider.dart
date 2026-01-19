// lib/state/sim_provider.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pad.dart';
import 'pads_provider.dart';

final simProvider = Provider<SimController>((ref) => SimController(ref));

class SimController {
  SimController(this.ref);
  final Ref ref;
  Timer? _timer;
  final _rnd = Random();

  bool get running => _timer != null;

  void start() {
    if (_timer != null) return; // déjà en cours
    _timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      final pad = Pad.values[_rnd.nextInt(4)];
      final current = ref.read(padsProvider);
      final next = Map<Pad, int>.from(current);

      // petite variation aléatoire -3..+3 g
      const deltas = [-3, -2, -1, 0, 0, 0, 1, 2, 3];
      final v = (next[pad]! + deltas[_rnd.nextInt(deltas.length)]).clamp(
        0,
        2000,
      );
      next[pad] = v;

      ref.read(padsProvider.notifier).state = next;
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
