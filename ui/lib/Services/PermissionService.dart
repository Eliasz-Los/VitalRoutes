import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestPermissions() async {
    if (await arePermissionsGranted()) {
      print("✅ All permissions are already granted.");
      return true;
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    statuses.forEach((permission, status) {
      if (status.isPermanentlyDenied) {
        print("⚠ ${permission.toString()} is permanently denied! Opening app settings...");
        openAppSettings();
      } else {
        print("${permission.toString()} - ${status.isGranted ? "✅ Granted" : "❌ Denied"}");
      }
    });

    return allGranted;
  }

  Future<bool> arePermissionsGranted() async {
    return await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.locationWhenInUse.isGranted;
  }
}
