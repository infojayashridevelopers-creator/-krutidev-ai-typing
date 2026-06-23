import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';

class WordToolbar extends StatelessWidget {
  const WordToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final settings = provider.wordSettings;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF161b22),
        border: Border(bottom: BorderSide(color: Color(0xFF30363d))),
      ),
      child: Row(
        children: [
          const Text(
            'Word Toolbar:',
            style: TextStyle(color: Color(0xFF8b949e), fontSize: 12),
          ),
          const SizedBox(width: 12),

          // Font name
          _ToolbarDropdown<String>(
            value: settings.fontName,
            items: ['Kruti Dev 010', 'Kruti Dev 011', 'Kruti Dev 016', 'Arial'],
            onChanged: (v) {
              if (v != null) {
                settings.fontName = v;
                provider.applySettings();
              }
            },
          ),
          const SizedBox(width: 8),

          // Font size
          _ToolbarDropdown<double>(
            value: settings.fontSize,
            items: [10, 12, 14, 16, 18, 20, 24],
            onChanged: (v) {
              if (v != null) {
                settings.fontSize = v;
                provider.applySettings();
              }
            },
          ),
          const SizedBox(width: 12),

          // Formatting buttons
          _FmtButton(
            label: 'B',
            active: settings.bold,
            bold: true,
            onTap: () {
              settings.bold = !settings.bold;
              provider.sendVoiceCommand(settings.bold ? 'बोल्ड ऑन' : 'बोल्ड ऑफ');
            },
          ),
          _FmtButton(
            label: 'I',
            active: settings.italic,
            italic: true,
            onTap: () {
              settings.italic = !settings.italic;
              provider.sendVoiceCommand(settings.italic ? 'इटैलिक ऑन' : 'इटैलिक ऑफ');
            },
          ),
          _FmtButton(
            label: 'U',
            active: settings.underline,
            underline: true,
            onTap: () {
              settings.underline = !settings.underline;
              provider.sendVoiceCommand(settings.underline ? 'अंडरलाइन' : 'अंडरलाइन ऑफ');
            },
          ),
          const SizedBox(width: 12),

          // Alignment
          ...[
            (Icons.format_align_left, 'left'),
            (Icons.format_align_center, 'center'),
            (Icons.format_align_right, 'right'),
            (Icons.format_align_justify, 'justify'),
          ].map((pair) => _AlignButton(
                icon: pair.$1,
                alignment: pair.$2,
                active: settings.alignment == pair.$2,
                onTap: () {
                  settings.alignment = pair.$2;
                  provider.applySettings();
                },
              )),
        ],
      ),
    );
  }
}

class _ToolbarDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _ToolbarDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        border: Border.all(color: const Color(0xFF30363d)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items
              .map((i) => DropdownMenuItem(
                    value: i,
                    child: Text(
                      i.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          dropdownColor: const Color(0xFF161b22),
          isDense: true,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}

class _FmtButton extends StatelessWidget {
  final String label;
  final bool active;
  final bool bold;
  final bool italic;
  final bool underline;
  final VoidCallback onTap;

  const _FmtButton({
    required this.label,
    required this.active,
    required this.onTap,
    this.bold = false,
    this.italic = false,
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1f6feb).withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: active ? const Color(0xFF1f6feb) : const Color(0xFF30363d),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF58a6ff) : const Color(0xFF8b949e),
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              decoration: underline ? TextDecoration.underline : null,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _AlignButton extends StatelessWidget {
  final IconData icon;
  final String alignment;
  final bool active;
  final VoidCallback onTap;

  const _AlignButton({
    required this.icon,
    required this.alignment,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.only(right: 3),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1f6feb).withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: active ? const Color(0xFF1f6feb) : const Color(0xFF30363d),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 15,
          color: active ? const Color(0xFF58a6ff) : const Color(0xFF8b949e),
        ),
      ),
    );
  }
}
