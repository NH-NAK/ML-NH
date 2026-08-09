import 'package:flutter/material.dart';
import '../../services/skin_service.dart';
import '../widgets/progress_dialog.dart';

class SkinsTab extends StatefulWidget {
  const SkinsTab({super.key});

  @override
  State<SkinsTab> createState() => _SkinsTabState();
}

class _SkinsTabState extends State<SkinsTab> {
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        skinService.filterSkins(_searchController.text);
      });
    });
    
    // Automatically trigger fetch if not loaded
    if (!skinService.isSkinsLoaded) {
      _loadSkins();
    }
  }

  Future<void> _loadSkins() async {
    setState(() => _isLoading = true);
    await skinService.fetchSkinsFromApi();
    setState(() => _isLoading = false);
  }

  Future<void> _inject(String skinName, String url, String zip) async {
    InstallationProgressDialog.show(context, title: "កំពុងស៊កស្គីន $skinName...");
    setState(() => _isLoading = true);
    await skinService.downloadAndInjectSkin(skinName, url, zip);
    setState(() => _isLoading = false);
  }

  Future<void> _revert(String skinName, String zip) async {
    InstallationProgressDialog.show(context, title: "កំពុងលុបស្គីន $skinName...");
    setState(() => _isLoading = true);
    await skinService.revertSkin(skinName, zip);
    setState(() => _isLoading = false);
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!skinService.isSkinsLoaded) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00FFCC)),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ម៉ាស៊ីនមេ SKIN API:",
                style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: skinService.activeProvider,
                    dropdownColor: const Color(0xFF13131A),
                    iconEnabledColor: const Color(0xFF00FFCC),
                    style: const TextStyle(color: Color(0xFF00FFCC), fontWeight: FontWeight.bold, fontSize: 12),
                    items: const [
                      DropdownMenuItem(value: "NH-1", child: Text("NH-1")),
                      DropdownMenuItem(value: "NH-2", child: Text("NH-2")),
                    ],

                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          skinService.activeProvider = val;
                        });
                        _loadSkins();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "ស្វែងរក Hero ឬ Skin...",
                hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Colors.white30, size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        Expanded(
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FFCC)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: skinService.filteredHeroesData.length,
                  itemBuilder: (context, index) {
                    final hero = skinService.filteredHeroesData[index];
                    final String heroName = hero["heroInfo"]?["name"] ?? "Unknown Hero";
                    final String heroRole = hero["heroInfo"]?["role"] ?? "Role";
                    final String heroAvatar = hero["heroInfo"]?["portraitIcon"] ?? hero["heroInfo"]?["avatar"] ?? hero["heroInfo"]?["image"] ?? "";
                    final List<dynamic> skins = hero["skins"] ?? [];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.01),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.03)),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    heroAvatar,
                                    width: 38,
                                    height: 38,
                                    headers: const {'User-Agent': 'Mozilla/5.0'},
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00FFCC).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          heroName.isNotEmpty ? heroName.substring(0, 1).toUpperCase() : "?",
                                          style: const TextStyle(
                                            color: Color(0xFF00FFCC),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00FFCC).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    heroRole.split('/').first,
                                    style: const TextStyle(
                                      color: Color(0xFF00FFCC),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Text(
                              heroName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            iconColor: const Color(0xFF00FFCC),
                            collapsedIconColor: Colors.white30,
                             children: skins.map((skin) {
                              final String skinName = skin["name"] ?? "Skin Name";
                              final int skinId = skin["id"] ?? -1;
                              
                              // Find zip URL from defaultSkins mapping or direct zip field
                              String zipUrl = skin["url"] ?? skin["sc"] ?? "";
                              if (zipUrl.isEmpty) {
                                final defaultSkinEntry = (hero["defaultSkins"] as List<dynamic>?)?.firstWhere(
                                  (ds) => ds["skinInfo"] == skinId,
                                  orElse: () => null,
                                );
                                zipUrl = defaultSkinEntry?["sc"] ?? "";
                              }
                              
                              // Fallback to skinToSkin mapping if not found in defaultSkins
                              if (zipUrl.isEmpty && hero["skinToSkin"] != null) {
                                for (var sublist in hero["skinToSkin"]) {
                                  if (sublist is List) {
                                    final entry = sublist.firstWhere(
                                      (s) => s["skinInfo"] == skinId,
                                      orElse: () => null,
                                    );
                                    if (entry != null && entry["sc"] != null) {
                                      zipUrl = entry["sc"];
                                      break;
                                    }
                                  }
                                }
                              }

                              final String zipName = skin["zip"] ?? (zipUrl.isNotEmpty ? zipUrl.split('/').last.split('?').first : "${heroName.toLowerCase()}_skin.zip");
                              final String skinImage = skin["image"] ?? skin["icon"] ?? "";
                              final bool hasCustomSkinImage = skinImage.isNotEmpty && skinImage != heroAvatar;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          hasCustomSkinImage
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(6),
                                                  child: Image.network(
                                                    skinImage,
                                                    width: 34,
                                                    height: 34,
                                                    headers: const {'User-Agent': 'Mozilla/5.0'},
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => _buildTierBadge(skinName),
                                                  ),
                                                )
                                              : _buildTierBadge(skinName),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              skinName,
                                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),



                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: (zipUrl.isEmpty && zipName.isEmpty) ? null : () => _inject(skinName, zipUrl.isNotEmpty ? zipUrl : "https://raw.githubusercontent.com/SourceBMT95/NEWFIGHTER/main/BACKUP%20GUINEVERE.zip", zipName),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF00FFCC),
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            minimumSize: Size.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text("បំពាក់ស្គីន", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 6),
                                        OutlinedButton(
                                          onPressed: zipName.isEmpty ? null : () => _revert(skinName, zipName),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.redAccent,
                                            side: const BorderSide(color: Colors.redAccent),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            minimumSize: Size.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text("លុបស្គីន", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }


  Widget _buildTierBadge(String skinName) {
    String label = "MOD";
    Color color = const Color(0xFF00FFCC);

    final nameLower = skinName.toLowerCase();
    if (nameLower.contains("basic") || nameLower.contains("normal")) {
      label = "BSC";
      color = Colors.blueAccent;
    } else if (nameLower.contains("elite")) {
      label = "ELT";
      color = Colors.purpleAccent;
    } else if (nameLower.contains("special") || nameLower.contains("season")) {
      label = "SPC";
      color = Colors.amberAccent;
    } else if (nameLower.contains("epic") || nameLower.contains("lightborn")) {
      label = "EPC";
      color = Colors.orangeAccent;
    } else if (nameLower.contains("collector") || nameLower.contains("prime")) {
      label = "CLT";
      color = Colors.cyanAccent;
    } else if (nameLower.contains("legend") || nameLower.contains("kof") || nameLower.contains("anime")) {
      label = "LGD";
      color = Colors.redAccent;
    }

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

