import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/map_service.dart';
import '../widgets/progress_dialog.dart';
import '../widgets/staggered_animation.dart';
import '../widgets/cyber_glass_card.dart';

class MapHackTab extends StatefulWidget {
  const MapHackTab({super.key});

  @override
  State<MapHackTab> createState() => _MapHackTabState();
}

class _MapHackTabState extends State<MapHackTab> {
  bool _isLoading = false;
  String _selectedDroneMultiplier = "3x";

  Future<void> _handleDroneInstall() async {
    InstallationProgressDialog.show(context, title: "កំពុងដំឡើងដ្រូន $_selectedDroneMultiplier...");
    setState(() => _isLoading = true);
    await mapService.installDroneHack(_selectedDroneMultiplier);
    setState(() => _isLoading = false);
  }

  Future<void> _handleDroneRevert() async {
    InstallationProgressDialog.show(context, title: "កំពុងលុបដ្រូនចេញ...");
    setState(() => _isLoading = true);
    await mapService.revertDroneHack();
    setState(() => _isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          StaggeredSlideFadeTransition(
            index: 0,
            child: _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "មុខងារកែប្រែដ្រូន (DRONE VIEW)",
                    style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "កែប្រែកម្រិតកម្ពស់កាមេរ៉ាលើផែនទីហ្គេម ដើម្បីមើលឃើញប្លង់ទូលាយ ងាយស្រួលប្រយ័ត្នខ្លួនពីការលួចវាយប្រហារ។",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("កម្ពស់កាមេរ៉ាបច្ចុប្បន្ន:", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Text(
                        mapService.isDroneInstalled ? "${mapService.droneViewMultiplier.toString().replaceAll('.0', '')}x កំពុងដំណើរការ" : "1x ដើម",
                        style: const TextStyle(color: Color(0xFF00FFCC), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("ជ្រើសរើសកម្ពស់ដ្រូន:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedDroneMultiplier,
                            dropdownColor: const Color(0xFF13131A),
                            iconEnabledColor: const Color(0xFF00FFCC),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            items: mapService.droneMultipliers.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: mapService.isDroneInstalled ? null : (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedDroneMultiplier = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF00FFCC)))
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: mapService.isDroneInstalled ? null : _handleDroneInstall,
                            icon: const Icon(Icons.install_mobile, size: 16),
                            label: const Text("ដំឡើងដ្រូន"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00FFCC),
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: Colors.white12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: !mapService.isDroneInstalled ? null : _handleDroneRevert,
                            icon: const Icon(Icons.restore, size: 16),
                            label: const Text("លុបដ្រូនចេញ"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              disabledForegroundColor: Colors.white24,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return CyberGlassCard(
      glowColor: const Color(0xFF00FFCC),
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: child,
    );
  }
}
