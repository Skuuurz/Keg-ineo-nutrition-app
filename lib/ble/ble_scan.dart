// lib/ble/ble_scan.dart
import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleScanner {
  BleScanner() : _ble = FlutterReactiveBle();

  final FlutterReactiveBle _ble;

  /// Scan générique (tous les devices)
  Stream<DiscoveredDevice> scanAll() {
    return _ble.scanForDevices(
      withServices: const [],
      scanMode: ScanMode.lowLatency,
    );
  }

  /// Scan + filtre sur nom commençant par KEGINEO-
  Stream<DiscoveredDevice> scanKegIneo() {
    return scanAll().where((d) => d.name.toUpperCase().startsWith('KEGINEO-'));
  }

  /// Scan rapide 5 s → liste unique
  Future<List<DiscoveredDevice>> quickScan({
    Duration duration = const Duration(seconds: 5),
  }) async {
    final results = <DiscoveredDevice>[];
    final seen = <String>{};
    final sub = scanAll().listen((d) {
      if (seen.add(d.id)) results.add(d);
    });
    await Future.delayed(duration);
    await sub.cancel();
    return results;
  }
}
