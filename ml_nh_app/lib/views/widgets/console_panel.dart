import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/logger_service.dart';

class ConsolePanel extends StatefulWidget {
  const ConsolePanel({super.key});

  @override
  State<ConsolePanel> createState() => _ConsolePanelState();
}

class _ConsolePanelState extends State<ConsolePanel> {
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  late StreamSubscription<String> _subscription;

  @override
  void initState() {
    super.initState();
    // Subscribe to global log stream
    _subscription = logger.logStream.listen((logLine) {
      if (mounted) {
        setState(() {
          _logs.add(logLine);
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.terminal, color: Color(0xFF00FFCC), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "ONYX ENGINE CONSOLE",
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _logs.clear();
                  });
                },
                child: const Text(
                  "CLEAR",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 16),
          Expanded(
            child: _logs.isEmpty
                ? const Center(
                    child: Text(
                      "Console idle. No actions executed.",
                      style: TextStyle(color: Colors.white24, fontSize: 11),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      Color logColor = Colors.white70;
                      if (log.contains("[+]")) {
                        logColor = Colors.greenAccent;
                      } else if (log.contains("[-]")) {
                        logColor = Colors.redAccent;
                      } else if (log.contains("[*]")) {
                        logColor = const Color(0xFF00FFCC);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          log,
                          style: GoogleFonts.sourceCodePro(
                            color: logColor,
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
