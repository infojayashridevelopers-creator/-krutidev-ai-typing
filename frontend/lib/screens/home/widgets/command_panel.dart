import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../utils/constants.dart';

class CommandPanel extends StatelessWidget {
  const CommandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final commands = AppConstants.voiceCommandsFor(provider.selectedLanguage);
    final langLabel = provider.selectedLanguage == 'mr'
        ? 'मराठी'
        : 'हिंदी';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(Icons.keyboard_voice, color: Color(0xFF8b949e), size: 14),
              const SizedBox(width: 6),
              Text(
                '$langLabel COMMANDS',
                style: const TextStyle(
                  color: Color(0xFF8b949e),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: commands.length,
            itemBuilder: (context, i) {
              final cmd = commands[i];
              return _CommandTile(
                speak: cmd['speak']!,
                action: cmd['action']!,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CommandTile extends StatelessWidget {
  final String speak;
  final String action;

  const _CommandTile({required this.speak, required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<AppProvider>().sendVoiceCommand(speak),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF161b22),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF30363d)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1f6feb).withAlpha(38),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: const Color(0xFF1f6feb).withAlpha(76)),
              ),
              child: Text(
                speak,
                style: const TextStyle(
                  color: Color(0xFF58a6ff),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward, size: 12, color: Color(0xFF8b949e)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                action,
                style: const TextStyle(color: Color(0xFF8b949e), fontSize: 12),
              ),
            ),
            const Icon(Icons.touch_app, size: 14, color: Color(0xFF30363d)),
          ],
        ),
      ),
    );
  }
}
