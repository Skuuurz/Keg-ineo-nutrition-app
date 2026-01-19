import 'package:permission_handler/permission_handler.dart';

/// Demande les autorisations nécessaires pour le BLE.
/// Retourne true si tout est accordé.
Future<bool> ensureBlePermissions() async {
  final statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ].request();

  // On vérifie que chaque valeur de la Map est "granted"
  return statuses.values.every((status) => status.isGranted);
}
