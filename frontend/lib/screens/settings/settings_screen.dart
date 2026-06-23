import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: kIsWeb ? 3 : 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161b22),
        foregroundColor: Colors.white,
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF1f6feb),
          labelColor: const Color(0xFF58a6ff),
          unselectedLabelColor: const Color(0xFF8b949e),
          tabs: [
            const Tab(text: 'Word Settings'),
            const Tab(text: 'Voice Commands'),
            const Tab(text: 'About'),
            if (!kIsWeb) const Tab(text: 'Connection'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _WordSettingsTab(),
          _VoiceCommandsTab(),
          _AboutTab(),
          if (!kIsWeb) const _ConnectionTab(),
        ],
      ),
    );
  }
}

class _WordSettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.wordSettings;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader('Font Settings'),
        _SettingRow(
          label: 'Font Name',
          child: DropdownButton<String>(
            value: s.fontName,
            dropdownColor: const Color(0xFF161b22),
            style: const TextStyle(color: Colors.white),
            items: ['Kruti Dev 010', 'Kruti Dev 011', 'Kruti Dev 016']
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                s.fontName = v;
                provider.applySettings();
              }
            },
          ),
        ),
        _SettingRow(
          label: 'Font Size',
          child: Slider(
            value: s.fontSize,
            min: 8,
            max: 36,
            divisions: 28,
            label: s.fontSize.round().toString(),
            onChanged: (v) {
              s.fontSize = v;
              provider.applySettings();
            },
          ),
        ),
        const SizedBox(height: 20),
        _SectionHeader('Paragraph Settings'),
        _SettingRow(
          label: 'Alignment',
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'left', icon: Icon(Icons.format_align_left, size: 16)),
              ButtonSegment(value: 'center', icon: Icon(Icons.format_align_center, size: 16)),
              ButtonSegment(value: 'right', icon: Icon(Icons.format_align_right, size: 16)),
              ButtonSegment(value: 'justify', icon: Icon(Icons.format_align_justify, size: 16)),
            ],
            selected: {s.alignment},
            onSelectionChanged: (v) {
              s.alignment = v.first;
              provider.applySettings();
            },
          ),
        ),
        _SettingRow(
          label: 'Line Spacing: ${s.lineSpacing}',
          child: Slider(
            value: s.lineSpacing,
            min: 1.0,
            max: 3.0,
            divisions: 20,
            label: s.lineSpacing.toStringAsFixed(1),
            onChanged: (v) {
              s.lineSpacing = double.parse(v.toStringAsFixed(1));
              provider.applySettings();
            },
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => provider.applySettings(),
          icon: const Icon(Icons.check),
          label: const Text('Apply to Word'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF238636),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _VoiceCommandsTab extends StatefulWidget {
  @override
  State<_VoiceCommandsTab> createState() => _VoiceCommandsTabState();
}

class _VoiceCommandsTabState extends State<_VoiceCommandsTab> {
  String _selectedLang = 'hi';

  @override
  Widget build(BuildContext context) {
    final commands = AppConstants.voiceCommandsFor(_selectedLang);

    return Column(
      children: [
        // Language toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            children: AppConstants.languages.map((lang) {
              final selected = _selectedLang == lang['code'];
              return GestureDetector(
                onTap: () => setState(() => _selectedLang = lang['code']!),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF1f6feb)
                        : const Color(0xFF161b22),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF1f6feb)
                          : const Color(0xFF30363d),
                    ),
                  ),
                  child: Text(
                    '${lang['native']} (${lang['name']})',
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF8b949e),
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _SectionHeader(
                  _selectedLang == 'mr' ? 'मराठी व्हॉइस कमांड' : 'हिंदी वॉयस कमांड'),
              const SizedBox(height: 8),
              ...commands.map((cmd) => Card(
                    color: const Color(0xFF161b22),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1f6feb).withAlpha(38),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          cmd['speak']!,
                          style: const TextStyle(
                              color: Color(0xFF58a6ff), fontSize: 14),
                        ),
                      ),
                      title: Text(cmd['action']!,
                          style: const TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 12, color: Color(0xFF8b949e)),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _AboutTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(
          child: Column(
            children: [
              Icon(Icons.record_voice_over, size: 80, color: Color(0xFF1f6feb)),
              SizedBox(height: 16),
              Text(
                AppConstants.appName,
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Version ${AppConstants.appVersion}',
                style: TextStyle(color: Color(0xFF8b949e)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _SectionHeader('Tech Stack'),
        _InfoRow('Backend', 'Go 1.21+ (Gin, go-ole, Whisper)'),
        _InfoRow('Frontend', 'Flutter (Windows Desktop)'),
        _InfoRow('Database', 'SQLite'),
        _InfoRow('STT Engine', 'OpenAI Whisper'),
        _InfoRow('Word Automation', 'COM via go-ole'),
        const SizedBox(height: 24),
        _SectionHeader('Requirements'),
        _InfoRow('OS', 'Windows 10/11 (64-bit)'),
        _InfoRow('Font', 'Kruti Dev 010 must be installed'),
        _InfoRow('Word', 'Microsoft Word 2016 or later'),
        _InfoRow('Whisper', 'Python + Whisper installed'),
        _InfoRow('Permissions', 'Admin rights recommended'),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF58a6ff),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _SettingRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: Color(0xFF8b949e), fontSize: 13)),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Color(0xFF8b949e), fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ConnectionTab extends StatefulWidget {
  const _ConnectionTab();

  @override
  State<_ConnectionTab> createState() => _ConnectionTabState();
}

class _ConnectionTabState extends State<_ConnectionTab> {
  late TextEditingController _urlCtrl;
  String _savedMsg = '';

  @override
  void initState() {
    super.initState();
    _urlCtrl = TextEditingController(text: AppConstants.serverUrl);
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ApiService.saveServerUrl(_urlCtrl.text.trim());
    setState(() => _savedMsg = 'Saved! Restart the app or reconnect for changes to take effect.');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader('Server URL'),
        const Text(
          'Enter the IP address of the Windows PC running the backend.\nExample: http://192.168.1.5:8080',
          style: TextStyle(color: Color(0xFF8b949e), fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _urlCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'http://192.168.1.x:8080',
            hintStyle: const TextStyle(color: Color(0xFF484f58)),
            filled: true,
            fillColor: const Color(0xFF161b22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF30363d)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF30363d)),
            ),
            prefixIcon: const Icon(Icons.lan_outlined, color: Color(0xFF8b949e)),
          ),
          keyboardType: TextInputType.url,
          autocorrect: false,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save & Apply'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1f6feb),
            foregroundColor: Colors.white,
          ),
        ),
        if (_savedMsg.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(_savedMsg, style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
        ],
        const SizedBox(height: 32),
        _SectionHeader('How to find your PC IP'),
        const Text(
          '1. On the Windows PC, open PowerShell\n'
          '2. Run: ipconfig\n'
          '3. Look for "IPv4 Address" under your WiFi adapter\n'
          '4. Enter it here as: http://<that-IP>:8080\n\n'
          'Make sure your phone and PC are on the same WiFi network.',
          style: TextStyle(color: Color(0xFF8b949e), fontSize: 13, height: 1.6),
        ),
      ],
    );
  }
}
