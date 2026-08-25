import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/shell_service.dart';
import 'tabs/system_tab.dart';
import 'tabs/map_hack_tab.dart';
import 'tabs/skins_tab.dart';
import 'tabs/tweaks_tab.dart';
import 'widgets/cyber_pulsing_indicator.dart';
import 'widgets/cyber_glass_card.dart';
import 'widgets/console_panel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _showTerminal = false;

  final List<Widget> _tabs = const [
    SystemTab(),
    MapHackTab(),
    SkinsTab(),
    TweaksTab(),
  ];

  @override
  void initState() {
    super.initState();
    shellService.checkRootStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      shellService.requestStoragePermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF00FFCC);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Main Layout Column
              Column(
                children: [
                  _buildHeaderPanel(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.05),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<int>(_currentIndex),
                        child: _tabs[_currentIndex],
                      ),
                    ),
                  ),
                  const SizedBox(height: 96), // Spacer for dock and terminal
                ],
              ),

              // Sliding Terminal Console drawer
              _buildTerminalDrawer(),

              // Floating Bottom Neon Dock
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildFloatingDock(activeColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderPanel() {
    final statusColor = (shellService.isRooted || 
        (shellService.isShizukuRunning && shellService.isShizukuPermissionGranted)) 
        ? Colors.greenAccent 
        : Colors.amberAccent;

    final String statusText = (shellService.isRooted || 
        (shellService.isShizukuRunning && shellService.isShizukuPermissionGranted))
        ? "ACTIVE: ${shellService.activeExecutionMode.split(' ').first.toUpperCase()}"
        : "ADB MODE";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CyberGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: 14,
        glowColor: statusColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  CyberPulsingIndicator(color: statusColor, size: 10),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "NH-SKIN-MLBB",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          statusText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Terminal Drawer Toggle Button
                IconButton(
                  icon: Icon(
                    Icons.terminal,
                    color: _showTerminal ? const Color(0xFF00FFCC) : Colors.white54,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      _showTerminal = !_showTerminal;
                    });
                  },
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  tooltip: 'Toggle Console Terminal',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF00FFCC), size: 18),
                  onPressed: () {
                    setState(() {
                      shellService.checkRootStatus();
                    });
                  },
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  tooltip: 'Re-scan Root Status',
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: () async {
                    final ok = await shellService.launchGame();
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("មិនអាចបើកហ្គេមបានទេ! សូមពិនិត្យមើលថាតើហ្គេមត្រូវបានដំឡើងឬនៅ។"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFCC),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("ចូលហ្គេម", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalDrawer() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      left: 16,
      right: 16,
      bottom: _showTerminal ? 92 : -220,
      height: 200,
      child: const CyberGlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 14,
        glowColor: Color(0xFF00FFCC),
        child: ConsolePanel(),
      ),
    );
  }

  Widget _buildFloatingDock(Color activeColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeColor.withOpacity(0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: activeColor.withOpacity(0.04),
            blurRadius: 16,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDockItem(0, Icons.developer_board_outlined, "ប្រព័ន្ធ", activeColor),
          _buildDockItem(1, Icons.map_outlined, "ដ្រូន view", activeColor),
          _buildDockItem(2, Icons.palette_outlined, "ស្គីន", activeColor),
          _buildDockItem(3, Icons.tune_outlined, "មុខងារ", activeColor),
        ],
      ),
    );
  }

  Widget _buildDockItem(int index, IconData icon, String label, Color activeColor) {
    final bool isActive = _currentIndex == index;
    final inactiveColor = Colors.white38;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? activeColor.withOpacity(0.25) : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.orbitron(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
