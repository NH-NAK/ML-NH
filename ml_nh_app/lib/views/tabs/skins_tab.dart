import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/skin_service.dart';
import '../widgets/progress_dialog.dart';
import '../widgets/staggered_animation.dart';
import '../widgets/cyber_glass_card.dart';

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

  Color _getRoleColor(String role) {
    final roleLower = role.toLowerCase();
    if (roleLower.contains("assassin")) return const Color(0xFFFF007F); // Neon Pink
    if (roleLower.contains("fighter")) return const Color(0xFFFF5500); // Neon Orange
    if (roleLower.contains("mage")) return const Color(0xFF9400D3); // Purple
    if (roleLower.contains("marksman")) return const Color(0xFF00FFCC); // Cyan
    if (roleLower.contains("tank")) return const Color(0xFFFFCC00); // Gold
    if (roleLower.contains("support")) return const Color(0xFF00E5FF); // Teal
    return const Color(0xFF00FFCC);
  }

  void _showSkinOptionsSheet(BuildContext context, Map<String, dynamic> hero) {
    final String heroName = hero["heroInfo"]?["name"] ?? "Unknown Hero";
    final String heroAvatar = hero["heroInfo"]?["portraitIcon"] ?? hero["heroInfo"]?["avatar"] ?? hero["heroInfo"]?["image"] ?? "";
    final List<dynamic> skins = hero["skins"] ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return CyberGlassCard(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          borderRadius: 24,
          glowColor: const Color(0xFF00FFCC),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Sheet
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          heroAvatar,
                          width: 38,
                          height: 38,
                          cacheWidth: 114,
                          cacheHeight: 114,
                          headers: const {'User-Agent': 'Mozilla/5.0'},
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 38,
                            height: 38,
                            color: Colors.white12,
                            child: const Icon(Icons.person, color: Colors.white30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            heroName.toUpperCase(),
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "ជ្រើសរើសស្គីនសម្រាប់បំពាក់ ឬលុបចេញ",
                            style: TextStyle(color: Colors.white54, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white38, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 20),
              
              // Skin Lists
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: skins.length,
                  itemBuilder: (context, index) {
                    final skin = skins[index];
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

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.04)),
                      ),
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
                                          width: 36,
                                          height: 36,
                                          cacheWidth: 108,
                                          cacheHeight: 108,
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
                                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: (zipUrl.isEmpty && zipName.isEmpty) ? null : () {
                                  Navigator.pop(context);
                                  _inject(skinName, zipUrl.isNotEmpty ? zipUrl : "https://raw.githubusercontent.com/SourceBMT95/NEWFIGHTER/main/BACKUP%20GUINEVERE.zip", zipName);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00FFCC),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                child: const Text("បំពាក់", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton(
                                onPressed: zipName.isEmpty ? null : () {
                                  Navigator.pop(context);
                                  _revert(skinName, zipName);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  side: const BorderSide(color: Colors.redAccent),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                child: const Text("លុប", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
        // Provider Selection & Search Box inside Glass Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: CyberGlassCard(
            padding: const EdgeInsets.all(12),
            borderRadius: 16,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ម៉ាស៊ីនមេ SKIN API:",
                      style: GoogleFonts.orbitron(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
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
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "ស្វែងរក Hero ឬ Skin...",
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
                      prefixIcon: Icon(Icons.search, color: Colors.white30, size: 16),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Grid List of Heroes
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FFCC)))
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  cacheExtent: 800,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: skinService.filteredHeroesData.length,
                  itemBuilder: (context, index) {
                    final hero = skinService.filteredHeroesData[index];
                    final String heroName = hero["heroInfo"]?["name"] ?? "Unknown Hero";
                    final String heroRole = hero["heroInfo"]?["role"] ?? "Fighter";
                    final String heroAvatar = hero["heroInfo"]?["portraitIcon"] ?? hero["heroInfo"]?["avatar"] ?? hero["heroInfo"]?["image"] ?? "";
                    final Color roleGlow = _getRoleColor(heroRole);

                    return StaggeredSlideFadeTransition(
                      index: index,
                      child: GestureDetector(
                        onTap: () => _showSkinOptionsSheet(context, hero),
                        child: CyberGlassCard(
                          padding: EdgeInsets.zero,
                          borderRadius: 16,
                          glowColor: roleGlow,
                          child: Stack(
                            children: [
                              // Avatar background image
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    heroAvatar,
                                    cacheWidth: 300,
                                    cacheHeight: 360,
                                    headers: const {'User-Agent': 'Mozilla/5.0'},
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.white.withOpacity(0.05),
                                      child: Center(
                                        child: Text(
                                          heroName.isNotEmpty ? heroName.substring(0, 1).toUpperCase() : "?",
                                          style: TextStyle(color: roleGlow, fontSize: 32, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Dark gradient mask
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.0),
                                        Colors.black.withOpacity(0.2),
                                        Colors.black.withOpacity(0.85),
                                      ],
                                      stops: const [0.0, 0.4, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              // Card Info Text
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Hero Role badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: roleGlow.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: roleGlow.withOpacity(0.4), width: 0.8),
                                      ),
                                      child: Text(
                                        heroRole.split('/').first.toUpperCase(),
                                        style: TextStyle(
                                          color: roleGlow,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Hero Name
                                    Text(
                                      heroName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 4.0,
                                            color: Colors.black54,
                                            offset: Offset(0, 1.5),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
      width: 36,
      height: 36,
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
