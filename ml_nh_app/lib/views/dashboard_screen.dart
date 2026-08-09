import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/shell_service.dart';
import 'tabs/system_tab.dart';
import 'tabs/map_hack_tab.dart';
import 'tabs/skins_tab.dart';
import 'tabs/tweaks_tab.dart';
import 'widgets/console_panel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    shellService.checkRootStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF07070A),
              Color(0xFF0F0F16),
              Color(0xFF07070A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeaderPanel(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    SystemTab(),
                    MapHackTab(),
                    SkinsTab(),
                    TweaksTab(),
                  ],
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }

  Widget _buildHeaderPanel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFCC).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00FFCC).withOpacity(0.2), width: 1.5),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF00FFCC),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "NH-SKIN-MLBB",
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (shellService.isRooted || (shellService.isShizukuRunning && shellService.isShizukuPermissionGranted)) ? "PRIVILEGES ACTIVE (${shellService.activeExecutionMode.toUpperCase()})" : "ADB/NON-ROOT MODE ACTIVE",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: (shellService.isRooted || (shellService.isShizukuRunning && shellService.isShizukuPermissionGranted)) ? Colors.greenAccent : Colors.amberAccent,
                      letterSpacing: 1.0,
                    ),
                  ),


                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00FFCC)),
            onPressed: () {
              setState(() {
                shellService.checkRootStatus();
              });
            },
            tooltip: 'Re-scan Root Status',
          )
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF00FFCC),
        labelColor: const Color(0xFF00FFCC),
        unselectedLabelColor: Colors.white38,
        labelStyle: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: "ប្រព័ន្ធ", icon: Icon(Icons.developer_board_outlined, size: 18)),
          Tab(text: "ដ្រូន view", icon: Icon(Icons.map_outlined, size: 18)),
          Tab(text: "ស្គីន", icon: Icon(Icons.palette_outlined, size: 18)),
          Tab(text: "មុខងារផ្សេងៗ", icon: Icon(Icons.tune_outlined, size: 18)),
        ],

      ),
    );
  }
}
