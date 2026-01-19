import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pad.dart';

/// état simple : poids (en grammes) pour chaque plateau
final padsProvider = StateProvider<Map<Pad, int>>(
  (ref) => {Pad.A: 0, Pad.B: 0, Pad.C: 0, Pad.D: 0},
);
