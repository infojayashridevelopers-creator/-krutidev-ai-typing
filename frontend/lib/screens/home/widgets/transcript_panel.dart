import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';

class TranscriptPanel extends StatelessWidget {
  const TranscriptPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final transcripts = provider.transcripts;

    return Container(
      color: const Color(0xFF0d1117),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF161b22),
              border: Border(bottom: BorderSide(color: Color(0xFF30363d))),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: Color(0xFF8b949e), size: 16),
                const SizedBox(width: 8),
                const Text(
                  'LIVE TRANSCRIPT',
                  style: TextStyle(
                    color: Color(0xFF8b949e),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                if (transcripts.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => context.read<AppProvider>().clearTranscripts(),
                    icon: const Icon(Icons.clear_all, size: 14, color: Color(0xFF8b949e)),
                    label: const Text('Clear',
                        style: TextStyle(color: Color(0xFF8b949e), fontSize: 12)),
                  ),
              ],
            ),
          ),

          // Latest result highlight
          if (provider.lastUnicodeText.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161b22),
                border: Border.all(
                    color: const Color(0xFF1f6feb).withAlpha(128)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Latest Recognition',
                        style: TextStyle(
                          color: Color(0xFF58a6ff),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1f6feb).withAlpha(38),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          provider.selectedLanguage == 'mr'
                              ? 'मराठी'
                              : 'हिंदी',
                          style: const TextStyle(
                              color: Color(0xFF58a6ff), fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Text: ',
                          style: TextStyle(
                              color: Color(0xFF8b949e), fontSize: 12)),
                      Expanded(
                        child: Text(
                          provider.lastUnicodeText,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy,
                            size: 14, color: Color(0xFF8b949e)),
                        onPressed: () => Clipboard.setData(
                            ClipboardData(text: provider.lastUnicodeText)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF30363d)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kruti: ',
                          style: TextStyle(
                              color: Color(0xFF8b949e), fontSize: 12)),
                      Expanded(
                        child: Text(
                          provider.lastKrutiText,
                          style: const TextStyle(
                            color: Color(0xFF3fb950),
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy,
                            size: 14, color: Color(0xFF8b949e)),
                        onPressed: () => Clipboard.setData(
                            ClipboardData(text: provider.lastKrutiText)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Transcript history
          Expanded(
            child: transcripts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic_none,
                            color: Color(0xFF30363d), size: 64),
                        SizedBox(height: 12),
                        Text(
                          'No transcripts yet.\nPress the microphone to start speaking.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFF8b949e), fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: transcripts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final t = transcripts[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161b22),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF30363d)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${t.timestamp.hour}:${t.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                      color: Color(0xFF8b949e), fontSize: 10),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: t.language == 'mr'
                                        ? const Color(0xFF2d1b69)
                                        : const Color(0xFF0e2a4a),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    t.languageLabel,
                                    style: TextStyle(
                                      color: t.language == 'mr'
                                          ? const Color(0xFFb39ddb)
                                          : const Color(0xFF58a6ff),
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () =>
                                      context.read<AppProvider>().sendVoiceCommand(t.unicodeText),
                                  child: const Icon(Icons.replay,
                                      size: 14, color: Color(0xFF58a6ff)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(t.unicodeText,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              t.krutiText,
                              style: const TextStyle(
                                  color: Color(0xFF3fb950),
                                  fontSize: 12,
                                  fontFamily: 'monospace'),
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
  }
}
