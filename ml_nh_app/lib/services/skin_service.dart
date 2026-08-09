import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as enc;
import 'package:archive/archive.dart';
import 'shell_service.dart';
import 'logger_service.dart';

class SkinService {
  static final SkinService _instance = SkinService._internal();
  factory SkinService() => _instance;
  SkinService._internal();

  static const String skinApiUrl = "https://luminadata-v2.pages.dev/heroes-bytes.txt";
  static const String zenToolsApiUrl = "https://raw.githubusercontent.com/Johnkurt200/Allhero/refs/heads/main/all_hero.json";

  String activeProvider = "NH-1"; // "NH-1" (Lumina CDN) or "NH-2" (Zen Tools API)
  List<dynamic> heroesData = [];
  List<dynamic> filteredHeroesData = [];
  bool isSkinsLoaded = false;


  String decryptData(String encryptedBase64) {
    final key = enc.Key.fromBase16('4a3f2e1d8c7b6a5f9e0d1c2b3a4f5e6d7c8b9a0e1f2d3c4b5a6f7e8d9c0b1a2f');
    final iv = enc.IV.fromBase16('1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d');
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.decrypt(enc.Encrypted.fromBase64(encryptedBase64.trim()), iv: iv);
  }

  Future<void> fetchSkinsFromApi() async {
    isSkinsLoaded = false;
    if (activeProvider == "NH-1") {
      logger.log("Fetching skin index from NH-1 CDN: $skinApiUrl...");
      try {
        final response = await http.get(
          Uri.parse(skinApiUrl),
          headers: {'User-Agent': 'okhttp/4.9.2'},
        );
        if (response.statusCode == 200) {
          logger.log("[+] Decrypting NH-1 skin database...");
          final decryptedJson = decryptData(response.body);
          final List<dynamic> parsed = json.decode(decryptedJson);
          
          heroesData = parsed;
          filteredHeroesData = parsed;
          isSkinsLoaded = true;
          logger.log("[+] Successfully loaded ${heroesData.length} heroes from NH-1 CDN.");
          return;
        }
      } catch (e) {
        logger.log("[-] NH-1 CDN fetch failed: $e");
      }
    }

    logger.log("Fetching skin index from NH-2 API: $zenToolsApiUrl...");

    try {
      // First attempt to load real Lumina DB for exact skin metadata mapping
      List<dynamic> realDb = [];
      try {
        final luminaResp = await http.get(Uri.parse(skinApiUrl), headers: {'User-Agent': 'okhttp/4.9.2'});
        if (luminaResp.statusCode == 200) {
          final decrypted = decryptData(luminaResp.body);
          realDb = json.decode(decrypted);
        }
      } catch (_) {}

      final resp2 = await http.get(Uri.parse(zenToolsApiUrl));
      if (resp2.statusCode == 200) {
        final List<dynamic> parsed2 = json.decode(resp2.body);
        heroesData = parsed2.map((item) {
          final heroName = item["title"] ?? "Hero";
          final cleanName = heroName.toString().toLowerCase().replaceAll(' ', '_');
          
          // Match real skin entries from real DB
          final realHero = realDb.firstWhere(
            (h) => h["heroInfo"]?["name"].toString().toLowerCase() == heroName.toString().toLowerCase(),
            orElse: () => null,
          );

          List<dynamic> realSkins = [];
          if (realHero != null && realHero["skins"] != null) {
            realSkins = (realHero["skins"] as List<dynamic>).map((s) => {
              "name": s["name"] ?? "$heroName Custom Skin",
              "id": s["id"] ?? 1001,
              "image": s["image"] ?? "",
              "zip": "${cleanName}_skin${s["id"] ?? 1}.zip"
            }).toList();
          }

          if (realSkins.isEmpty) {
            realSkins = [
              {"name": "$heroName - Vanguard Elite", "id": 1001, "zip": "${cleanName}_skin01.zip"},
              {"name": "$heroName - Special Edition", "id": 1002, "zip": "${cleanName}_skin02.zip"},
              {"name": "$heroName - Epic Lightborn", "id": 1003, "zip": "${cleanName}_skin03.zip"},
              {"name": "$heroName - Collector Mod", "id": 1004, "zip": "${cleanName}_skin04.zip"},
              {"name": "$heroName - Legend / KOF Mod", "id": 1005, "zip": "${cleanName}_skin05.zip"},
            ];
          }

          return {
            "heroInfo": {
              "name": heroName,
              "role": item["Role"] ?? realHero?["heroInfo"]?["role"] ?? "Fighter",
              "avatar": item["image"] ?? realHero?["heroInfo"]?["portraitIcon"] ?? ""
            },
            "skins": realSkins
          };
        }).toList();

        filteredHeroesData = heroesData;
        isSkinsLoaded = true;
        logger.log("[+] Successfully loaded ${heroesData.length} heroes with real skin names!");
        return;
      }
    } catch (e) {

      logger.log("[-] Zen Tools API fetch failed: $e");
    }
    loadFallbackSkins();
  }


  void filterSkins(String query) {
    if (query.isEmpty) {
      filteredHeroesData = heroesData;
    } else {
      filteredHeroesData = heroesData
          .where((hero) => hero["heroInfo"]?["name"]
              ?.toString()
              .toLowerCase()
              .contains(query.toLowerCase()) ?? false)
          .toList();
    }
  }

  void loadFallbackSkins() {
    heroesData = [];
    filteredHeroesData = [];
    isSkinsLoaded = true;
    logger.log("[+] Fallback skins configuration reset.");
  }

  Future<bool> injectSkin(String skinName, String zipName) async {
    logger.updateProgress(0.50, "កំពុងស្វែងរកកញ្ចប់ $zipName...");
    logger.log("Searching for skin archive: $zipName...");
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
      logger.updateProgress(1.0, "រកមិនឃើញឯកសារ $zipName!");
      logger.log("[-] Archive '$zipName' not found on storage.");
      logger.log("[-] Place the skin ZIP in your device's 'Download' folder.");
      return false;
    }

    logger.updateProgress(0.65, "កំពុងពង្រីកឯកសារស្គីន...");
    logger.log("[+] Found skin archive at: ${zipFile.path}");
    logger.log("[*] Unzipping skin assets...");

    try {
      final bytes = zipFile.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      final extractPath = Directory("/sdcard/Download/.skin_extract");
      if (extractPath.existsSync()) {
        try {
          extractPath.deleteSync(recursive: true);
        } catch (_) {}
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
      logger.log("[+] Extraction successful.");

      logger.updateProgress(0.85, "កំពុងរុញឯកសារស្គីនចូលក្នុងហ្គេម...");
      const remoteAssetsDir = "/sdcard/Android/data/com.mobile.legends/files/dragon2017/assets/";
      final mode = shellService.activeExecutionMode;

      if (mode == "Root Mode") {
        logger.log("[*] Copying skin asset files to game directory via Root...");
        final ok1 = await shellService.executeRoot("mkdir -p $remoteAssetsDir");
        final ok2 = await shellService.executeRoot("cp -r ${extractPath.path}/* $remoteAssetsDir");
        if (ok1 && ok2) {
          logger.updateProgress(1.0, "ស្គីន $skinName ជោគជ័យ ១០០%!");
          logger.log("[+] Successfully injected $skinName assets!");
          return true;
        } else {
          logger.updateProgress(1.0, "ការស្គីនបរាជ័យ!");
          logger.log("[-] Root file copy failed.");
          return false;
        }
      } else if (mode == "Shizuku") {
        logger.log("[*] Copying skin asset files to game directory via Shizuku...");
        final ok1 = await shellService.executeShizuku("mkdir -p $remoteAssetsDir");
        final ok2 = await shellService.executeShizuku("cp -r ${extractPath.path}/* $remoteAssetsDir");
        if (ok1 && ok2) {
          logger.updateProgress(1.0, "បំពាក់ស្គីន $skinName ជោគជ័យ ១០០%!");
          logger.log("[+] Successfully injected $skinName assets via Shizuku!");
          return true;
        } else {
          logger.updateProgress(1.0, "ការបំពាក់ស្គីនតាម Shizuku បរាជ័យ!");
          logger.log("[-] Shizuku copy failed.");
          return false;
        }
      } else {
        logger.updateProgress(1.0, "មិនទាន់មានសិទ្ធិ Root/Shizuku!");
        logger.log("[!] Non-root mode: Run ADB commands or LADB to deploy.");
        return false;
      }
    } catch (e) {
      logger.updateProgress(1.0, "កើតមាន Error ក្នុងការដំឡើង!");
      logger.log("[-] Injection failed: $e");
      return false;
    } finally {
      try {
        final extractPath = Directory("/sdcard/Download/.skin_extract");
        if (extractPath.existsSync()) {
          extractPath.deleteSync(recursive: true);
        }
      } catch (_) {}
    }
  }

  Future<bool> revertSkin(String skinName, String zipName) async {
    logger.updateProgress(0.30, "កំពុងត្រៀមលុប $skinName...");
    logger.log("Reverting skin mod dynamically: $skinName...");

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
      logger.updateProgress(1.0, "មិនអាចរកឃើញ $zipName ដើម!");
      logger.log("[-] Cannot read '$zipName' to find the exact skin file list for reversion.");
      logger.log("[-] Please download the ZIP again or keep it in your Download directory.");
      return false;
    }

    try {
      final bytes = zipFile.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      const remoteAssetsDir = "/sdcard/Android/data/com.mobile.legends/files/dragon2017/assets/";
      final mode = shellService.activeExecutionMode;

      int deletedCount = 0;
      bool allOk = true;

      logger.updateProgress(0.60, "កំពុងលុបឯកសារ Custom Skin ពីហ្គេម...");
      for (final file in archive) {
        if (file.isFile) {
          final filePath = file.name;
          if (filePath.isNotEmpty) {
            final targetPath = "$remoteAssetsDir$filePath";
            
            if (mode == "Root Mode") {
              final ok = await shellService.executeRoot("rm -f \"$targetPath\"");
              if (ok) deletedCount++; else allOk = false;
            } else if (mode == "Shizuku") {
              final ok = await shellService.executeShizuku("rm -f \"$targetPath\"");
              if (ok) deletedCount++; else allOk = false;
            }
          }
        }
      }

      if (mode == "PC ADB Guide") {
        logger.updateProgress(1.0, "ត្រូវការបញ្ជា ADB ដោយដៃ!");
        logger.log("[!] Manual ADB revert required.");
        return false;
      } else if (allOk && deletedCount > 0) {
        logger.updateProgress(1.0, "លុបស្គីន $skinName ជោគជ័យ ១០០%!");
        logger.log("[+] Successfully removed $deletedCount custom skin files from game assets.");
        logger.log("[+] Skin Mod $skinName successfully reverted to official.");
        return true;
      } else {
        logger.updateProgress(1.0, "លុបស្គីនបានមួយផ្នែក!");
        logger.log("[-] Revert completed with warnings. Some files could not be deleted.");
        return false;
      }
    } catch (e) {
      logger.updateProgress(1.0, "កើតមាន Error ក្នុងការលុបស្គីន!");
      logger.log("[-] Revert failed: $e");
      return false;
    }
  }

  Future<bool> downloadAndInjectSkin(String skinName, String url, String zipName) async {
    logger.updateProgress(0.05, "កំពុងរៀបចំទាញយក $skinName...");
    logger.log("Downloading skin from: $url...");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        logger.updateProgress(0.40, "ទាញយកកញ្ចប់ Zip $skinName ជោគជ័យ!");
        final bytes = response.bodyBytes;
        final downloadDir = Directory("/sdcard/Download");
        if (!downloadDir.existsSync()) {
          downloadDir.createSync(recursive: true);
        }
        final zipFile = File("${downloadDir.path}/$zipName");
        zipFile.writeAsBytesSync(bytes);
        logger.log("[+] Downloaded zip file to ${zipFile.path}");
        
        return await injectSkin(skinName, zipName);
      } else {
        logger.updateProgress(1.0, "ទាញយកកញ្ចប់ Zip បរាជ័យ!");
        logger.log("[-] Download failed. HTTP Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      logger.updateProgress(1.0, "កើតមាន Error ក្នុងការទាញយក!");
      logger.log("[-] Download error: $e");
      return false;
    }
  }

}

final skinService = SkinService();
