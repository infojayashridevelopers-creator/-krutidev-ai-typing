import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF161b22),
      child: Row(
        children: [
          Icon(
            provider.isProcessing
                ? Icons.sync
                : provider.isRecording
                    ? Icons.fiber_manual_record
                    : Icons.check_circle,
            size: 12,
            color: provider.isProcessing
                ? const Color(0xFFd29922)
                : provider.isRecording
                    ? const Color(0xFFda3633)
                    : const Color(0xFF3fb950),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.statusMessage.isEmpty ? 'Ready' : provider.statusMessage,
              style: const TextStyle(color: Color(0xFF8b949e), fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Text(
            'Kruti Dev AI Typing v1.0  |  Windows Only  |  © 2024',
            style: TextStyle(color: Color(0xFF484f58), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
