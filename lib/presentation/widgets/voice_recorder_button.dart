import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecorderButton extends StatefulWidget {
  final Function(String audioPath) onRecordingComplete;

  const VoiceRecorderButton({super.key, required this.onRecordingComplete});

  @override
  State<VoiceRecorderButton> createState() => _VoiceRecorderButtonState();
}

class _VoiceRecorderButtonState extends State<VoiceRecorderButton> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  int _recordDuration = 0;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      // Show warning on web
      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Les messages vocaux ne sont pas encore supportés sur le web. '
                'Veuillez utiliser l\'application mobile.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        String filePath;

        if (kIsWeb) {
          // For web, use a simple path - the recorder handles it internally
          filePath = 'voice_${DateTime.now().millisecondsSinceEpoch}';
        } else {
          // For mobile, get temporary directory
          final directory = await getTemporaryDirectory();
          filePath =
              '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        }

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );

        setState(() {
          _isRecording = true;
          _recordDuration = 0;
        });

        // Update duration every second
        while (_isRecording) {
          await Future.delayed(const Duration(seconds: 1));
          if (_isRecording) {
            setState(() {
              _recordDuration++;
            });
          }
        }
      } else {
        print('🔴 Microphone permission denied');
      }
    } catch (e) {
      print('🔴 Error starting recording: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _recordDuration = 0;
      });

      if (path != null) {
        print('🟢 Recording saved at: $path');
        widget.onRecordingComplete(path);
      } else {
        print('🔴 Recording path is null');
      }
    } catch (e) {
      print('🔴 Error stopping recording: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red : const Color(0xFF6C63FF),
          shape: BoxShape.circle,
        ),
        child: _isRecording
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mic, color: Colors.white, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    _formatDuration(_recordDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : const Icon(Icons.mic, color: Colors.white, size: 24),
      ),
    );
  }
}
