import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/logger_service.dart';

class InstallationProgressDialog extends StatefulWidget {
  final String title;

  const InstallationProgressDialog({
    super.key,
    this.title = "កំពុងដំណើរការដំឡើង...",
  });

  static Future<void> show(BuildContext context, {String title = "កំពុងដំណើរការដំឡើង..."}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InstallationProgressDialog(title: title),
    );
  }

  @override
  State<InstallationProgressDialog> createState() => _InstallationProgressDialogState();
}

class _InstallationProgressDialogState extends State<InstallationProgressDialog> {
  int _percentage = 0;
  double _progress = 0.0;
  String _status = "កំពុងរៀបចំប្រព័ន្ធ...";
  late StreamSubscription<Map<String, dynamic>> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = logger.progressStream.listen((data) {
      if (mounted) {
        setState(() {
          _progress = (data['progress'] as double?) ?? 0.0;
          _percentage = (data['percentage'] as int?) ?? 0;
          _status = (data['status'] as String?) ?? "កំពុងដំណើរការ...";
        });
        if (_percentage >= 100) {
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F0F16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFF00FFCC).withOpacity(0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    strokeWidth: 8,
                    backgroundColor: Colors.white10,
                    color: const Color(0xFF00FFCC),
                  ),
                ),
                Text(
                  "$_percentage%",
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00FFCC),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                minHeight: 8,
                backgroundColor: Colors.white10,
                color: const Color(0xFF00FFCC),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
