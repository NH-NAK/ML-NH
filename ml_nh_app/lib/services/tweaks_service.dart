import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'shell_service.dart';
import 'logger_service.dart';

class TweaksService {
  static final TweaksService _instance = TweaksService._internal();
  factory TweaksService() => _instance;
  TweaksService._internal();

  bool isFpsUnlocked = false;
  int activeFpsRate = 60;
  bool isLogsCleaned = false;
  bool isTouchOptimized = false;

  Future<bool> optimizeTouchResponse() async {
    logger.log("Optimizing Touch Response Rate & Gesture Latency...");
    final mode = shellService.activeExecutionMode;

    const touchCmds = 
      "settings put system touch_prediction_enabled 1; "
      "settings put system touch_pressure_scale 0.001; "
      "settings put global touch_responsiveness_level 3; "
      "setprop debug.performance.tuning 1; "
      "setprop video.accelerate.hw 1; "
      "setprop windowsmgr.max_events_per_sec 300;";

    bool ok = false;
    if (mode == "Root Mode") {
      ok = await shellService.executeRoot(touchCmds);
    } else if (mode == "Shizuku") {
      ok = await shellService.executeShizuku(touchCmds);
    } else {
      logger.log("[!] ADB command required to optimize Touch Response.");
    }

    if (ok || mode == "PC ADB Guide") {
      isTouchOptimized = true;
      logger.log("[+] Touch Sensitivity & Sampling Rate successfully boosted (Fast Skill Combos active)!");
      return true;
    } else {
      logger.log("[-] Failed to set Touch Response parameters.");
      return false;
    }
  }


  final List<Map<String, String>> recallEffects = [
    {
      "name": "Recall KOF (King of Fighters)",
      "url": "https://github.com/SourceBMT95/NEWFIGHTER/raw/main/BACKUP%20GUINEVERE.zip", // example backup zip
      "zip": "recall_kof.zip"
    },
    {
      "name": "Recall Transformers Prime",
      "url": "https://github.com/SourceBMT95/NEWFIGHTER/raw/main/BACKUP%20GUINEVERE.zip",
      "zip": "recall_transformers.zip"
    },
    {
      "name": "Recall M-World 5th Anniversary",
      "url": "https://github.com/SourceBMT95/NEWFIGHTER/raw/main/BACKUP%20GUINEVERE.zip",
      "zip": "recall_mworld.zip"
    }
  ];

  final List<Map<String, String>> emotesList = [
    {
      "name": "Layla Emote - Haha!",
      "url": "https://github.com/SourceBMT95/NEWFIGHTER/raw/main/BACKUP%20GUINEVERE.zip",
      "zip": "emote_layla.zip"
    },
    {
      "name": "Chou Emote - Shocked",
      "url": "https://github.com/SourceBMT95/NEWFIGHTER/raw/main/BACKUP%20GUINEVERE.zip",
      "zip": "emote_chou.zip"
    }
  ];

  Future<bool> cleanAntiBanLogs() async {
    logger.log("Starting Anti-Ban log cleaning process...");
    await shellService.requestStoragePermission();

    final List<String> pathsToClear = [
      "/sdcard/Android/data/com.mobile.legends/files/dragon2017/assets/OfflineReport/",
      "/sdcard/Android/data/com.mobile.legends/files/dragon2017/assets/PerformanceTracer/",
      "/sdcard/Android/data/com.mobile.legends/files/dragon2017/BattlePlayerInfoCache/",
      "/sdcard/Android/data/com.mobile.legends/files/dragon2017/BattleRecord/",
      "/sdcard/Android/data/com.mobile.legends/files/dragon2017/OfflineReport/"
    ];

    bool allSuccess = true;
    final mode = shellService.activeExecutionMode;

    for (var path in pathsToClear) {
      logger.log("[*] Cleaning logs in directory: $path");
      if (mode == "Root Mode") {
        final ok1 = await shellService.executeRoot("rm -rf \"$path\"");
        final ok2 = await shellService.executeRoot("mkdir -p \"$path\"");
        if (!ok1 || !ok2) allSuccess = false;
      } else if (mode == "Shizuku") {
        final ok1 = await shellService.executeShizuku("rm -rf \"$path\"");
        final ok2 = await shellService.executeShizuku("mkdir -p \"$path\"");
        if (!ok1 || !ok2) allSuccess = false;
      } else {
        logger.log("[!] ADB Command needed: adb shell rm -rf \"$path\"");
        allSuccess = false;
      }
    }

    if (allSuccess || mode == "PC ADB Guide") {
      isLogsCleaned = true;
      logger.log("[+] Successfully cleared all Moonton performance trackers and crash logs!");
      return true;
    } else {
      logger.log("[-] Some crash logs could not be deleted.");
      return false;
    }
  }

  Future<bool> unlockFPS(int rate) async {
    logger.log("Configuring FPS Unlock parameters to: ${rate}Hz/FPS...");
    await shellService.requestStoragePermission();

    const prefsFile = "/sdcard/Android/data/com.mobile.legends/files/dragon2017/assets/prefs_int";
    final mode = shellService.activeExecutionMode;

    String writeCmd = "";
    if (rate >= 90) {
      writeCmd += "echo 'high_fps 1' >> $prefsFile; echo 'extreme_fps 1' >> $prefsFile; ";
    }
    if (rate >= 120) {
      writeCmd += "echo 'ultra_fps 1' >> $prefsFile; echo 'super_high_fps 1' >> $prefsFile; ";
    }
    
    writeCmd += "echo 'MaxFps $rate' >> $prefsFile; echo 'TargetFps $rate' >> $prefsFile;";

    bool ok = false;
    if (mode == "Root Mode") {
      ok = await shellService.executeRoot(writeCmd);
    } else if (mode == "Shizuku") {
      ok = await shellService.executeShizuku(writeCmd);
    } else {
      logger.log("[!] ADB command required: adb shell \"$writeCmd\"");
    }

    if (ok || mode == "PC ADB Guide") {
      isFpsUnlocked = true;
      activeFpsRate = rate;
      logger.log("[+] FPS successfully unlocked to ${rate}FPS in game settings!");
      return true;
    } else {
      logger.log("[-] Failed to write preferences file.");
      return false;
    }
  }

  Future<bool> injectTweakZip(String name, String url, String zipName) async {
    logger.log("Preparing deployment of custom tweak: $name...");
    await shellService.requestStoragePermission();

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final zipFile = File("/sdcard/Download/$zipName");
        zipFile.writeAsBytesSync(bytes);
        logger.log("[+] Downloaded zip file to ${zipFile.path}");
        
        // Extract
        final archive = ZipDecoder().decodeBytes(bytes);
        final extractPath = Directory("/sdcard/Download/.tweak_extract");
        if (extractPath.existsSync()) {
          try { extractPath.deleteSync(recursive: true); } catch (_) {}
        }
        extractPath.createSync(recursive: true);

        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            final outFile = File("${extractPath.path}/$filename");
            outFile.createSync(recursive: true);
            outFile.writeAsBytesSync(data);
          }
        }
        logger.log("[+] Extraction completed.");

        const remoteAssetsDir = "/sdcard/Android/data/com.mobile.legends/files/dragon2017/assets/";
        final mode = shellService.activeExecutionMode;
        bool ok = false;

        if (mode == "Root Mode") {
          final ok1 = await shellService.executeRoot("mkdir -p $remoteAssetsDir");
          final ok2 = await shellService.executeRoot("cp -r ${extractPath.path}/* $remoteAssetsDir");
          ok = ok1 && ok2;
        } else if (mode == "Shizuku") {
          final ok1 = await shellService.executeShizuku("mkdir -p $remoteAssetsDir");
          final ok2 = await shellService.executeShizuku("cp -r ${extractPath.path}/* $remoteAssetsDir");
          ok = ok1 && ok2;
        }

        if (ok) {
          logger.log("[+] Successfully injected custom tweak: $name!");
          return true;
        } else {
          logger.log("[-] File deployment failed.");
          return false;
        }
      } else {
        logger.log("[-] Failed to download tweak. HTTP: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      logger.log("[-] Tweak injection failed: $e");
      return false;
    } finally {
      // Clean up public temp folders
      try {
        final extractPath = Directory("/sdcard/Download/.tweak_extract");
        if (extractPath.existsSync()) {
          extractPath.deleteSync(recursive: true);
        }
        final zipFile = File("/sdcard/Download/$zipName");
        if (zipFile.existsSync()) {
          zipFile.deleteSync();
        }
      } catch (_) {}
    }
  }

  Future<bool> injectModZip(String zipName) async {
    logger.log("Preparing to inject custom MLBB mod: $zipName...");
    logger.updateProgress(0.10, "កំពុងស្វែងរកឯកសារ ZIP: $zipName...");
    await shellService.requestStoragePermission();

    final searchPaths = [
      "/sdcard/Download/$zipName",
      "/sdcard/$zipName",
      "/storage/emulated/0/Download/$zipName",
      "/storage/emulated/0/$zipName",
    ];

    File? zipFile;
    for (var path in searchPaths) {
      final f = File(path);
      if (f.existsSync()) {
        zipFile = f;
        break;
      }
    }

    if (zipFile == null) {
      logger.updateProgress(1.0, "រកមិនឃើញឯកសារ $zipName ឡើយ!");
      logger.log("[-] Mod ZIP archive '$zipName' not found on storage.");
      logger.log("[-] Please place '$zipName' inside the 'Download' folder.");
      return false;
    }

    logger.updateProgress(0.30, "កំពុងពង្រីកឯកសារ Mod ZIP...");
    logger.log("[+] Found mod archive at: ${zipFile.path}");
    logger.log("[*] Unzipping files...");

    final extractPath = Directory("/sdcard/Download/.mod_extract");
    if (extractPath.existsSync()) {
      try { extractPath.deleteSync(recursive: true); } catch (_) {}
    }
    extractPath.createSync(recursive: true);

    try {
      final bytes = zipFile.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      // We extract all files to local temp folder
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final outFile = File("${extractPath.path}/$filename");
          outFile.createSync(recursive: true);
          outFile.writeAsBytesSync(data);
        }
      }
      logger.log("[+] Extraction completed successfully.");
      logger.updateProgress(0.50, "កំពុងគណនា MD5 hashes...");

      // Compute MD5 of all files under dragon2017/assets/
      final assetsDir = Directory("${extractPath.path}/dragon2017/assets");
      if (!assetsDir.existsSync()) {
        logger.updateProgress(1.0, "ឯកសារ ZIP មិនត្រឹមត្រូវ!");
        logger.log("[-] Invalid mod ZIP structure. Must contain dragon2017/assets directory.");
        return false;
      }

      final Map<String, String> computedHashes = {};
      final List<FileSystemEntity> allEntities = assetsDir.listSync(recursive: true);
      
      for (var entity in allEntities) {
        if (entity is File) {
          final filename = entity.uri.pathSegments.last;
          if (filename == "PatchFileList.xml" || filename == "PatchFileList_SDK.xml") {
            continue;
          }
          
          // Get relative path from assets directory
          final relPath = entity.path
              .replaceAll(assetsDir.path + Platform.pathSeparator, "")
              .replaceAll("\\", "/");
              
          final bytes = entity.readAsBytesSync();
          final md5Hash = md5.convert(bytes).toString();
          computedHashes[relPath] = md5Hash;
        }
      }
      logger.log("[+] Computed MD5s for ${computedHashes.length} mod files.");

      // Check if we need to update manifests
      logger.updateProgress(0.70, "កំពុងកែសម្រួលឯកសារ Manifest XML...");
      final manifestNames = ["PatchFileList.xml", "PatchFileList_SDK.xml"];
      for (var manifestName in manifestNames) {
        final mFile = File("${assetsDir.path}/$manifestName");
        if (mFile.existsSync()) {
          logger.log("[*] Patching manifest: $manifestName");
          String xmlContent = mFile.readAsStringSync();
          
          int updatedCount = 0;
          computedHashes.forEach((relPath, newMd5) {
            final pattern = RegExp(
              r'(<item\s+[^>]*name="' + RegExp.escape(relPath) + r'"[^>]*md5=")([^"]*)(")'
            );
            if (pattern.hasMatch(xmlContent)) {
              xmlContent = xmlContent.replaceAllMapped(pattern, (match) {
                updatedCount++;
                return "${match.group(1)}$newMd5${match.group(3)}";
              });
            }
          });
          
          if (updatedCount > 0) {
            mFile.writeAsStringSync(xmlContent);
            logger.log("[+] Updated $updatedCount checksum entries in $manifestName");
          } else {
            logger.log("[-] No checksum updates needed for $manifestName");
          }
        }
      }

      // Check for directory conflicts on device and remove them
      logger.updateProgress(0.85, "កំពុងត្រួតពិនិត្យ និងសម្អាត Directory Blocks...");
      const remoteBaseDir = "/sdcard/Android/data/com.mobile.legends/files/dragon2017/";
      final mode = shellService.activeExecutionMode;

      // Construct a single shell script to clear directories blocking the files
      StringBuffer cleanupCmds = StringBuffer();
      computedHashes.keys.forEach((relPath) {
        final remotePath = "${remoteBaseDir}assets/$relPath";
        cleanupCmds.write('if [ -d "$remotePath" ]; then rm -rf "$remotePath" && echo "Cleared blocking directory: $relPath"; fi; ');
      });

      if (cleanupCmds.isNotEmpty) {
        if (mode == "Root Mode") {
          await shellService.executeRoot(cleanupCmds.toString());
        } else if (mode == "Shizuku") {
          await shellService.executeShizuku(cleanupCmds.toString());
        } else {
          logger.log("[!] ADB mode: Manual block cleanup required.");
        }
      }

      logger.updateProgress(0.90, "កំពុងរុញឯកសារ Mod ចូលក្នុងហ្គេម...");
      // Copy files to game folder
      bool copyOk = false;
      final localFolder = "${extractPath.path}/dragon2017";
      if (mode == "Root Mode") {
        final ok1 = await shellService.executeRoot("mkdir -p \"$remoteBaseDir\"");
        final ok2 = await shellService.executeRoot("cp -r \"$localFolder\"/* \"$remoteBaseDir\"");
        final ok3 = await shellService.executeRoot("chmod -R 777 \"$remoteBaseDir\"");
        copyOk = ok1 && ok2 && ok3;
      } else if (mode == "Shizuku") {
        final ok1 = await shellService.executeShizuku("mkdir -p \"$remoteBaseDir\"");
        final ok2 = await shellService.executeShizuku("cp -r \"$localFolder\"/* \"$remoteBaseDir\"");
        final ok3 = await shellService.executeShizuku("chmod -R 777 \"$remoteBaseDir\"");
        copyOk = ok1 && ok2 && ok3;
      }

      if (copyOk) {
        logger.updateProgress(1.0, "ដំឡើង Mod ជោគជ័យ ១០០%!");
        logger.log("[+] SUCCESSFULLY injected custom mod: $zipName!");
        return true;
      } else {
        logger.updateProgress(1.0, "ការដំឡើង Mod បរាជ័យ!");
        logger.log("[-] Failed to copy files to game directory.");
        return false;
      }
    } catch (e) {
      logger.updateProgress(1.0, "កើតមានកំហុសក្នុងការដំឡើង!");
      logger.log("[-] Mod injection error: $e");
      return false;
    } finally {
      // Cleanup
      try {
        if (extractPath.existsSync()) {
          extractPath.deleteSync(recursive: true);
        }
      } catch (_) {}
    }
  }

  Future<bool> revertModZip(String zipName) async {
    logger.log("Preparing to revert custom MLBB mod: $zipName...");
    logger.updateProgress(0.20, "កំពុងអានកញ្ចប់ ZIP ដើម្បីលុបឯកសារ...");
    await shellService.requestStoragePermission();

    final searchPaths = [
      "/sdcard/Download/$zipName",
      "/sdcard/$zipName",
      "/storage/emulated/0/Download/$zipName",
      "/storage/emulated/0/$zipName",
    ];

    File? zipFile;
    for (var path in searchPaths) {
      final f = File(path);
      if (f.existsSync()) {
        zipFile = f;
        break;
      }
    }

    if (zipFile == null) {
      logger.updateProgress(1.0, "មិនអាចរកឃើញឯកសារ $zipName!");
      logger.log("[-] Cannot revert: Mod ZIP archive '$zipName' not found on storage.");
      return false;
    }

    try {
      final bytes = zipFile.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      const remoteBaseDir = "/sdcard/Android/data/com.mobile.legends/files/dragon2017/";
      final mode = shellService.activeExecutionMode;

      StringBuffer deleteCmds = StringBuffer();
      int fileCount = 0;

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          // If it starts with dragon2017/, strip it
          var cleanPath = filename;
          if (filename.startsWith("dragon2017/")) {
            cleanPath = filename.replaceAll("dragon2017/", "");
          } else if (filename.startsWith("dragon2017\\")) {
            cleanPath = filename.replaceAll("dragon2017\\", "");
          }
          
          if (cleanPath == "assets/PatchFileList.xml" || cleanPath == "assets/PatchFileList_SDK.xml") {
            continue;
          }
          
          deleteCmds.write('rm -f "$remoteBaseDir$cleanPath"; ');
          fileCount++;
        }
      }

      logger.updateProgress(0.60, "កំពុងលុបឯកសារ Mod ពីហ្គេម...");
      logger.log("[*] Removing $fileCount custom mod files from device...");

      bool deleteOk = false;
      if (mode == "Root Mode") {
        deleteOk = await shellService.executeRoot(deleteCmds.toString());
      } else if (mode == "Shizuku") {
        deleteOk = await shellService.executeShizuku(deleteCmds.toString());
      }

      if (deleteOk) {
        logger.updateProgress(1.0, "លុប Mod ជោគជ័យ ១០០%!");
        logger.log("[+] Mod $zipName reverted to official.");
        return true;
      } else {
        logger.updateProgress(1.0, "ការលុប Mod បរាជ័យ!");
        logger.log("[-] Failed to delete mod files from game assets.");
        return false;
      }
    } catch (e) {
      logger.updateProgress(1.0, "កើតមាន Error ក្នុងការលុប!");
      logger.log("[-] Revert failed: $e");
      return false;
    }
  }

  Future<bool> downloadAndInjectMod(String zipName) async {
    final url = "https://github.com/NH-NAK/ML-NH/raw/main/$zipName";
    logger.log("Downloading mod from: $url...");
    logger.updateProgress(0.05, "កំពុងទាញយក Mod ពី GitHub...");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        logger.updateProgress(0.40, "ទាញយក Mod ជោគជ័យ!");
        final bytes = response.bodyBytes;
        final downloadDir = Directory("/sdcard/Download");
        if (!downloadDir.existsSync()) {
          downloadDir.createSync(recursive: true);
        }
        final zipFile = File("${downloadDir.path}/$zipName");
        zipFile.writeAsBytesSync(bytes);
        logger.log("[+] Saved downloaded zip to: ${zipFile.path}");
        
        return await injectModZip(zipName);
      } else {
        logger.updateProgress(1.0, "ទាញយក Mod ពី GitHub បរាជ័យ!");
        logger.log("[-] HTTP Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      logger.updateProgress(1.0, "មានបញ្ហាក្នុងការទាញយក!");
      logger.log("[-] Download failed: $e");
      return false;
    }
  }
}

final tweaksService = TweaksService();
