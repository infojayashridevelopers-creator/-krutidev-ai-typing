import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';

class RecordButton extends StatelessWidget {
  const RecordButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final state = provider.recordingState;

    return Column(
      children: [
        const Text(
          'VOICE RECORDING',
          style: TextStyle(
            color: Color(0xFF8b949e),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            if (state == RecordingState.idle) {
              provider.startRecording();
            } else if (state == RecordingState.recording) {
              provider.stopAndProcess();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getColor(state),
              boxShadow: [
                BoxShadow(
                  color: _getColor(state).withValues(alpha: 0.4),
                  blurRadius: state == RecordingState.recording ? 30 : 10,
                  spreadRadius: state == RecordingState.recording ? 5 : 0,
                ),
              ],
            ),
            child: Icon(
              _getIcon(state),
              color: Colors.white,
              size: 52,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _getLabel(state),
          style: TextStyle(
            color: _getColor(state),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        if (state == RecordingState.recording) ...[
          const SizedBox(height: 8),
          const _PulsingDots(),
        ],
        if (state == RecordingState.recording) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => context.read<AppProvider>().cancelRecording(),
            icon: const Icon(Icons.cancel, color: Colors.red, size: 16),
            label: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ],
    );
  }

  Color _getColor(RecordingState state) {
    switch (state) {
      case RecordingState.idle:
        return const Color(0xFF1f6feb);
      case RecordingState.recording:
        return const Color(0xFFda3633);
      case RecordingState.processing:
        return const Color(0xFF388bfd);
    }
  }

  IconData _getIcon(RecordingState state) {
    switch (state) {
      case RecordingState.idle:
        return Icons.mic;
      case RecordingState.recording:
        return Icons.stop;
      case RecordingState.processing:
        return Icons.hourglass_top;
    }
  }

  String _getLabel(RecordingState state) {
    switch (state) {
      case RecordingState.idle:
        return 'Tap to Record';
      case RecordingState.recording:
        return 'Recording... (tap to stop)';
      case RecordingState.processing:
        return 'Processing...';
    }
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 8,
            height: 8 + (_controller.value * 6),
            decoration: BoxDecoration(
              color: const Color(0xFFda3633).withValues(alpha: 0.4 + _controller.value * 0.6),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
