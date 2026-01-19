// lib/ble/ble_device_connector.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleDeviceConnector {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  StreamSubscription<ConnectionStateUpdate>? _connectionSub;
  StreamSubscription<List<int>>? _notifySub;

  bool _connected = false;
  bool get isConnected => _connected;

  // Pour write (optionnel)
  String? _deviceId;
  Uuid? _serviceId;
  Uuid? _rxWriteCharId;

  // Buffer pour JSON fragmenté
  final StringBuffer _rxBuffer = StringBuffer();

  Future<void> connectAndListen({
    required String deviceId,
    required Uuid serviceId,
    required Uuid txNotifyCharId, // ESP32 -> App (NOTIFY)
    Uuid? rxWriteCharId, // App -> ESP32 (WRITE) optionnel
    required void Function(String rawJson) onLine,
    void Function(bool connected)? onConnection,
    void Function(Object e)? onError,
  }) async {
    await disconnect();

    _deviceId = deviceId;
    _serviceId = serviceId;
    _rxWriteCharId = rxWriteCharId;

    _connectionSub = _ble
        .connectToDevice(
          id: deviceId,
          connectionTimeout: const Duration(seconds: 12),
        )
        .listen(
          (update) async {
            if (update.connectionState == DeviceConnectionState.connected) {
              _connected = true;
              onConnection?.call(true);

              // Android: petit délai avant discover/CCCD
              await Future.delayed(const Duration(milliseconds: 400));

              final qTx = QualifiedCharacteristic(
                deviceId: deviceId,
                serviceId: serviceId,
                characteristicId: txNotifyCharId,
              );

              _notifySub = _ble
                  .subscribeToCharacteristic(qTx)
                  .listen(
                    (data) {
                      if (data.isEmpty) return;
                      final chunk = utf8.decode(data, allowMalformed: true);
                      _rxBuffer.write(chunk);
                      _extractJsonObjects(onLine);
                    },
                    onError: (e) {
                      debugPrint('❌ BLE notify error: $e');
                      onError?.call(e);
                    },
                  );
            }

            if (update.connectionState == DeviceConnectionState.disconnected) {
              _connected = false;
              onConnection?.call(false);
            }
          },
          onError: (e) {
            _connected = false;
            onConnection?.call(false);
            onError?.call(e);
          },
        );
  }

  // App -> ESP32 (si Barnabé veut recevoir des commandes)
  Future<void> sendCommand(String text) async {
    if (!_connected ||
        _deviceId == null ||
        _serviceId == null ||
        _rxWriteCharId == null) {
      debugPrint('⚠️ sendCommand ignoré (pas connecté ou rxWriteCharId null)');
      return;
    }

    final qRx = QualifiedCharacteristic(
      deviceId: _deviceId!,
      serviceId: _serviceId!,
      characteristicId: _rxWriteCharId!,
    );

    final bytes = utf8.encode(text);
    await _ble.writeCharacteristicWithResponse(qRx, value: bytes);
  }

  void _extractJsonObjects(void Function(String rawJson) onLine) {
    var s = _rxBuffer.toString();

    while (true) {
      final start = s.indexOf('{');
      if (start < 0) break;
      final end = s.indexOf('}', start);
      if (end < 0) break;

      final jsonStr = s.substring(start, end + 1).trim();
      if (jsonStr.isNotEmpty) onLine(jsonStr);

      s = s.substring(end + 1);
    }

    _rxBuffer
      ..clear()
      ..write(s);
  }

  Future<void> disconnect() async {
    await _notifySub?.cancel();
    await _connectionSub?.cancel();
    _notifySub = null;
    _connectionSub = null;
    _connected = false;

    _deviceId = null;
    _serviceId = null;
    _rxWriteCharId = null;

    _rxBuffer.clear();
  }

  void dispose() => disconnect();
}
