// lib/models/pad.dart
enum Pad { A, B, C, D }

extension PadLabel on Pad {
  String get label {
    switch (this) {
      case Pad.A:
        return 'A';
      case Pad.B:
        return 'B';
      case Pad.C:
        return 'C';
      case Pad.D:
        return 'D';
    }
  }
}
