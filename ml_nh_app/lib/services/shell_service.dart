import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shizuku_api/shizuku_api.dart';
import 'package:path_provider/path_provider.dart';
import 'logger_service.dart';

class ShellService {
  static final ShellService _instance = ShellService._internal();
  factory ShellService() => _instance;
  ShellService._internal();

  bool isRooted = false;
  String activeExecutionMode = "Root Mode"; // Root Mode, Shizuku, or PC ADB Guide
  final _shizukuApiPlugin = ShizukuApi();

  Future<bool> executeRoot(String command) async {
    try {
      final res = await Process.run('su', ['-c', command]);
      if (res.exitCode == 0) {
        return true;
      } else {
        logger.log("[-] Root command failed (exit code ${res.exitCode}): ${res.stderr.toString().trim()}");
        return false;
      }
    } catch (e) {
      logger.log("[-] Root execution failed: $e");
      return false;
    }
  }

  Future<bool> executeShizuku(String command) async {
    try {
      final isBinderRunning = await _shizukuApiPlugin.pingBinder() ?? false;
      if (!isBinderRunning) {
        logger.log("[-] Shizuku service is not running. Please start Shizuku app first.");
        return false;
      }
      final hasPermission = await _shizukuApiPlugin.checkPermission() ?? false;
      if (!hasPermission) {
        logger.log("[*] Requesting Shizuku authorization...");
        final granted = await _shizukuApiPlugin.requestPermission() ?? false;
        if (!granted) {
          logger.log("[-] Shizuku permission denied by user.");
          return false;
        }
      }
      logger.log("[*] Executing Shizuku command: $command");
      final output = await _shizukuApiPlugin.runCommand(command);
      logger.log("[+] Shizuku output: $output");
      return true;
    } catch (e) {
      logger.log("[-] Shizuku execution failed: $e");
      return false;
    }
  }

  bool isShizukuRunning = false;
  bool isShizukuPermissionGranted = false;

  Future<void> checkRootStatus() async {
    logger.log("Executing strict real-time Root & Shizuku verification...");
    
    // 1. Verify Shizuku Binder & Actual Granted Permission
    try {
      final isBinderRunning = await _shizukuApiPlugin.pingBinder() ?? false;
      if (isBinderRunning) {
        isShizukuRunning = true;
        final hasPerm = await _shizukuApiPlugin.checkPermission() ?? false;
        isShizukuPermissionGranted = hasPerm;
      } else {
        isShizukuRunning = false;
        isShizukuPermissionGranted = false;
      }
    } catch (_) {
      isShizukuRunning = false;
      isShizukuPermissionGranted = false;
    }

    // 2. Verify Actual Root Execution Permission
    try {
      final testRoot = await Process.run('su', ['-c', 'id']);
      if (testRoot.exitCode == 0 && testRoot.stdout.toString().contains('uid=0')) {
        isRooted = true;
        activeExecutionMode = "Root Mode";
        logger.log("[+] Verified Real Root Access (uid=0). Set to Root Mode.");
        return;
      } else {
        isRooted = false;
      }
    } catch (_) {
      isRooted = false;
    }

    // 3. Set Execution Mode based ONLY on actual granted privileges
    if (isShizukuRunning && isShizukuPermissionGranted) {
      activeExecutionMode = "Shizuku";
      logger.log("[+] Shizuku Authorized & Active. Set to Shizuku Mode.");
    } else {
      activeExecutionMode = "PC ADB Guide";
      logger.log("[-] No Root or Shizuku Permission granted. Mode: ADB Guide.");
    }

    // Create mini_patch folder automatically
    await createMiniPatchFolder();
  }

  Future<void> createMiniPatchFolder() async {
    try {
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final path = "${extDir.path}/mini_patch";
        final dir = Directory(path);
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
          logger.log("[+] Created mini_patch directory: $path");
        } else {
          logger.log("[*] mini_patch directory already exists.");
        }
      } else {
        logger.log("[-] Failed to get external storage directory.");
      }
    } catch (e) {
      logger.log("[-] Failed to create mini_patch directory: $e");
    }
  }



  Future<bool> requestStoragePermission() async {
    logger.log("Requesting All Files Access permission...");
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      logger.log("[+] All Files Access granted.");
      return true;
    } else {
      logger.log("[-] All Files Access denied. Please enable it in Settings.");
      return false;
    }
  }
}

final shellService = ShellService();
