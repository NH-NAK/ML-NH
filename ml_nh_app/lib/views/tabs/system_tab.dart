import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/shell_service.dart';
import '../../services/map_service.dart';
import '../../services/logger_service.dart';

class SystemTab extends StatefulWidget {
  const SystemTab({super.key});

  @override
  State<SystemTab> createState() => _SystemTabState();
}

class _SystemTabState extends State<SystemTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ព័ត៌មានប្រព័ន្ធដំណើរការ",
                  style: GoogleFonts.orbitron(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Divider(color: Colors.white12, height: 24),
                _buildSystemRow(
                  "ស្ថានភាព Root / Shizuku",
                  (shellService.isRooted || (shellService.isShizukuRunning && shellService.isShizukuPermissionGranted)) ? "អនុញ្ញាតរួចរាល់" : "មិនទាន់អនុញ្ញាត",
                  (shellService.isRooted || (shellService.isShizukuRunning && shellService.isShizukuPermissionGranted)) ? Colors.greenAccent : Colors.amberAccent,
                ),


                _buildSystemRow(
                  "របៀបដំណើរការ",
                  shellService.activeExecutionMode,
                  const Color(0xFF00FFCC),
                ),
                _buildSystemRow(
                  "ទីតាំង File ហ្គេម",
                  "com.mobile.legends/files",
                  Colors.white70,
                ),
                const SizedBox(height: 16),
                const Text(
                  "ជ្រើសរើសវិធីសាស្ត្រដំណើរការ App:",
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildModeButton("Root Mode", shellService.activeExecutionMode == "Root Mode", () {
                        setState(() {
                          shellService.activeExecutionMode = "Root Mode";
                        });
                        logger.log("Mode updated to Root Mode.");
                      }),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildModeButton("Shizuku", shellService.activeExecutionMode == "Shizuku", () {
                        setState(() {
                          shellService.activeExecutionMode = "Shizuku";
                        });
                        logger.log("Mode updated to Shizuku Mode.");
                      }),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildModeButton("PC ADB", shellService.activeExecutionMode == "PC ADB Guide", () {
                        setState(() {
                          shellService.activeExecutionMode = "PC ADB Guide";
                        });
                        logger.log("Mode updated to ADB Manual Command mode.");
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "កញ្ចប់មុខងារកំពុងដំណើរការ",
                  style: GoogleFonts.orbitron(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Divider(color: Colors.white12, height: 24),
                _buildBypassItem(
                  "កម្រិតកម្ពស់កាមេរ៉ាដ្រូន",
                  mapService.isDroneInstalled ? "${mapService.droneViewMultiplier.toInt()}x កំពុងដំណើរការ" : "ធម្មតា",
                  mapService.isDroneInstalled,
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: child,
    );
  }

  Widget _buildSystemRow(String title, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBypassItem(String name, String status, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                active ? Icons.check_circle : Icons.radio_button_unchecked,
                color: active ? const Color(0xFF00FFCC) : Colors.white24,
                size: 15,
              ),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          Text(
            status,
            style: TextStyle(
              color: active ? const Color(0xFF00FFCC) : Colors.white30,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF00FFCC).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? const Color(0xFF00FFCC) : Colors.white10,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: active ? const Color(0xFF00FFCC) : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
