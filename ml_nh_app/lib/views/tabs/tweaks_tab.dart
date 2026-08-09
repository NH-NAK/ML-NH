import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/tweaks_service.dart';
import '../../services/logger_service.dart';
import '../widgets/progress_dialog.dart';

class TweaksTab extends StatefulWidget {
  const TweaksTab({super.key});

  @override
  State<TweaksTab> createState() => _TweaksTabState();
}

class _TweaksTabState extends State<TweaksTab> {
  bool _isLoading = false;
  int _selectedFps = 90;


  Future<void> _handleLogsClean() async {
    InstallationProgressDialog.show(context, title: "កំពុងសំអាត LOGS...");
    logger.updateProgress(0.20, "កំពុងត្រួតពិនិត្យ Crash Reports...");
    setState(() => _isLoading = true);
    await tweaksService.cleanAntiBanLogs();
    logger.updateProgress(1.0, "សំអាត LOGS ការពារ BAN ជោគជ័យ ១០០%!");
    setState(() => _isLoading = false);
  }

  Future<void> _handleFpsUnlock() async {
    InstallationProgressDialog.show(context, title: "កំពុងបើកគន្លឹះ $_selectedFps FPS...");
    logger.updateProgress(0.30, "កំពុងកែសម្រួល Preferences Config...");
    setState(() => _isLoading = true);
    await tweaksService.unlockFPS(_selectedFps);
    logger.updateProgress(1.0, "បើកគន្លឹះ $_selectedFps FPS ជោគជ័យ ១០០%!");
    setState(() => _isLoading = false);
  }

  Future<void> _handleTweakInject(String name, String url, String zip) async {
    InstallationProgressDialog.show(context, title: "កំពុងដំឡើង $name...");
    logger.updateProgress(0.15, "កំពុងរៀបចំដំឡើង $name...");
    setState(() => _isLoading = true);
    await tweaksService.injectTweakZip(name, url, zip);
    logger.updateProgress(1.0, "ដំឡើង $name ជោគជ័យ ១០០%!");
    setState(() => _isLoading = false);
  }


  Future<void> _handleTouchOptimize() async {
    InstallationProgressDialog.show(context, title: "កំពុងបង្កើន Touch Response...");
    logger.updateProgress(0.25, "កំពុងដំឡើង Touch Sampling Rate & Gesture Latency...");
    setState(() => _isLoading = true);
    await tweaksService.optimizeTouchResponse();
    logger.updateProgress(1.0, "បង្កើន Touch Response ជោគជ័យ ១០០%!");
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [


          // 0. Touch Response Optimizer Card
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TOUCH RESPONSE OPTIMIZER",
                      style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Icon(
                      tweaksService.isTouchOptimized ? Icons.bolt : Icons.touch_app,
                      color: tweaksService.isTouchOptimized ? const Color(0xFF00FFCC) : Colors.white24,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "បង្កើនកម្រិត Sensitivity នៃអេក្រង់ប៉ះ (Touch Sampling Rate & Latency) ឱ្យឆ្លើយតបលឿនបំផុត សម្រាប់ Skill Combo ដូចជា Chou, Gusion, Fanny លឿនរហ័ស គ្មានទាក់។",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Divider(color: Colors.white12, height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Color(0xFF00FFCC)))
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleTouchOptimize,
                      icon: const Icon(Icons.speed, size: 16),
                      label: const Text("បង្កើន TOUCH SENSITIVITY (FAST COMBO)", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FFCC),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Anti-Ban Log Cleaner Card
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ប្រព័ន្ធលុប LOGS ការពារ BAN (ANTI-BAN)",
                      style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Icon(
                      tweaksService.isLogsCleaned ? Icons.verified : Icons.security,
                      color: tweaksService.isLogsCleaned ? const Color(0xFF00FFCC) : Colors.white24,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "សំអាតប្រវត្តិ Crash Logs និងប្រព័ន្ធទិន្នន័យ Telemetry របស់ Moonton ក្នុងទូរស័ព្ទ ដើម្បីកាត់បន្ថយហានិភ័យនៃការទប់ស្កាត់ (Ban Account)។",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Divider(color: Colors.white12, height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Color(0xFF00FFCC)))
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogsClean,
                      icon: const Icon(Icons.cleaning_services, size: 16),
                      label: const Text("សំអាត LOGS ការពារ BAN", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FFCC),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. FPS Unlocker Card
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "កែសម្រួលក្រាហ្វិក និង FPS",
                  style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  "បើកកម្រិត Frame Rate ខ្ពស់រលូនក្នុងហ្គេម Mobile Legends (អាស្រ័យលើអេក្រង់ទូរស័ព្ទរបស់អ្នក)។",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Divider(color: Colors.white12, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("ជ្រើសរើសកម្រិត FPS:", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedFps,
                          dropdownColor: const Color(0xFF13131A),
                          iconEnabledColor: const Color(0xFF00FFCC),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          items: const [
                            DropdownMenuItem(value: 60, child: Text("60 FPS (ធម្មតា)")),
                            DropdownMenuItem(value: 90, child: Text("90 FPS (លឿន)")),
                            DropdownMenuItem(value: 120, child: Text("120 FPS (លឿនបំផុត)")),
                          ],
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedFps = newValue;
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleFpsUnlock,
                      icon: const Icon(Icons.bolt, size: 16),
                      label: Text("បើកគន្លឹះ $_selectedFps FPS", style: const TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FFCC),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Custom Recall Effects Card
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "EFFECT RECALL ពិសេស",
                  style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Divider(color: Colors.white12, height: 24),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tweaksService.recallEffects.length,
                  itemBuilder: (context, index) {
                    final item = tweaksService.recallEffects[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(item["name"]!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ),
                          ElevatedButton(
                            onPressed: _isLoading ? null : () => _handleTweakInject(item["name"]!, item["url"]!, item["zip"]!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00FFCC),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Text("ដំឡើង", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Custom Emotes Card
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "EMOTES ពិសេស",
                  style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Divider(color: Colors.white12, height: 24),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tweaksService.emotesList.length,
                  itemBuilder: (context, index) {
                    final item = tweaksService.emotesList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(item["name"]!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ),
                          ElevatedButton(
                            onPressed: _isLoading ? null : () => _handleTweakInject(item["name"]!, item["url"]!, item["zip"]!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00FFCC),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Text("ដំឡើង", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
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
}
