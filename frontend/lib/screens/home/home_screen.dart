import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../main.dart' show KrutiDevApp;
import '../settings/settings_screen.dart';
import 'widgets/record_button.dart';
import 'widgets/transcript_panel.dart';
import 'widgets/command_panel.dart';
import 'widgets/status_bar.dart';
import 'widgets/word_toolbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1117),
      body: Column(
        children: [
          _buildTopBar(context),
          const WordToolbar(),
          Expanded(
            child: Row(
              children: [
                // Left panel - Controls
                _buildLeftPanel(context),
                const VerticalDivider(color: Color(0xFF30363d), width: 1),
                // Right panel - Transcript
                const Expanded(child: TranscriptPanel()),
              ],
            ),
          ),
          const StatusBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF161b22),
        border: Border(bottom: BorderSide(color: Color(0xFF30363d))),
      ),
      child: Row(
        children: [
          const Icon(Icons.record_voice_over, color: Color(0xFF58a6ff), size: 22),
          const SizedBox(width: 10),
          const Text(
            AppConstants.appName,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          // Language selector
          _LanguageSelector(),
          const SizedBox(width: 12),
          // Word connection status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: provider.wordConnected
                  ? const Color(0xFF1a4731)
                  : const Color(0xFF3d1f1f),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: provider.wordConnected ? Colors.greenAccent : Colors.redAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  provider.wordConnected ? 'Word Connected' : 'Word Disconnected',
                  style: TextStyle(
                    color: provider.wordConnected ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white60, size: 20),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white60, size: 20),
            onPressed: () => _confirmLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    return Container(
      width: 340,
      color: const Color(0xFF0d1117),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const RecordButton(),
          const SizedBox(height: 20),
          // Word automation — works from any device; COM runs on the backend server
          _buildWordActions(context),
          // Output actions (Copy/Share/Download)
          _buildOutputPanel(context),
          const SizedBox(height: 8),
          const Expanded(child: CommandPanel()),
        ],
      ),
    );
  }

  Widget _buildWordActions(BuildContext context) {
    final provider = context.read<AppProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WORD ACTIONS',
            style: TextStyle(
              color: Color(0xFF8b949e),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  icon: Icons.add_box_outlined,
                  label: 'New Doc',
                  color: const Color(0xFF1f6feb),
                  onTap: () => provider.newDocument(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionBtn(
                  icon: Icons.save_outlined,
                  label: 'Save',
                  color: const Color(0xFF238636),
                  onTap: () => _saveDialog(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionBtn(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'PDF',
                  color: const Color(0xFFda3633),
                  onTap: () => _pdfDialog(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOutputPanel(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (provider.lastKrutiText.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'OUTPUT',
              style: TextStyle(
                color: Color(0xFF8b949e),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF161b22),
                border: Border.all(color: const Color(0xFF30363d)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Record to see output here',
                  style: TextStyle(color: Color(0xFF484f58), fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final preview = provider.lastKrutiText.length > 60
        ? '${provider.lastKrutiText.substring(0, 60)}…'
        : provider.lastKrutiText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OUTPUT',
            style: TextStyle(
              color: Color(0xFF8b949e),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0d1117),
              border: Border.all(color: const Color(0xFF30363d)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              preview,
              style: const TextStyle(
                color: Color(0xFFe6edf3),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  icon: Icons.copy_outlined,
                  label: 'Copy',
                  color: const Color(0xFF1f6feb),
                  onTap: () => provider.copyToClipboard(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionBtn(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: const Color(0xFF8957e5),
                  onTap: () => provider.shareKrutiText(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionBtn(
                  icon: Icons.download_outlined,
                  label: '.docx',
                  color: const Color(0xFF1a7f37),
                  onTap: () => provider.downloadAsDocx(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(38),
          border: Border.all(color: color.withAlpha(102)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  void _saveDialog(BuildContext context) {
    final ctrl = TextEditingController(text: 'document');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Save Document'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'File name', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<AppProvider>().saveDocument(ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _pdfDialog(BuildContext context) {
    final ctrl = TextEditingController(text: 'export');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export as PDF'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'File name', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<AppProvider>().exportPDF(ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.clearToken();
              if (context.mounted) {
                runApp(const KrutiDevApp());
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// ── Language Selector ──────────────────────────────────────────────────────

class _LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF161b22),
        border: Border.all(color: const Color(0xFF30363d)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppConstants.languages.map((lang) {
          final isSelected = provider.selectedLanguage == lang['code'];
          return GestureDetector(
            onTap: () => provider.setLanguage(lang['code']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1f6feb)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lang['native']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF8b949e),
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    lang['name']!,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white70
                          : const Color(0xFF484f58),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
