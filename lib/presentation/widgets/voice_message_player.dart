import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class VoiceMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final bool isMe;

  const VoiceMessagePlayer({
    super.key,
    required this.audioUrl,
    required this.isMe,
  });

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = true;
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _loadAudioFile();
  }

  void _initPlayer() {
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  Future<void> _loadAudioFile() async {
    try {
      // On web, use URL directly without caching
      if (kIsWeb) {
        print('🌐 Loading audio on web: ${widget.audioUrl}');
        await _audioPlayer.setSourceUrl(widget.audioUrl);
        final duration = await _audioPlayer.getDuration();
        if (duration != null && mounted) {
          setState(() {
            _duration = duration;
            _isLoading = false;
          });
          print('🎵 Duration loaded: $duration');
        } else if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // On mobile, use file caching
      final tempDir = await getTemporaryDirectory();
      final fileName = widget.audioUrl.split('/').last.split('?').first;
      final file = File('${tempDir.path}/$fileName');

      // Check if file already exists in cache
      if (await file.exists()) {
        print('✅ Using cached audio: ${file.path}');
        _localFilePath = file.path;
      } else {
        print('🔵 Downloading audio from: ${widget.audioUrl}');

        // Download the file
        final response = await http.get(
          Uri.parse(widget.audioUrl),
          headers: {'Accept': '*/*'},
        );

        if (response.statusCode != 200) {
          print('🔴 Response body: ${response.body}');
          throw 'Failed to download audio: ${response.statusCode}';
        }

        // Save to cache
        await file.writeAsBytes(response.bodyBytes);
        _localFilePath = file.path;

        print(
          '🟢 Audio cached: $_localFilePath (${response.bodyBytes.length} bytes)',
        );
      }

      // Set source and get duration
      await _audioPlayer.setSourceDeviceFile(_localFilePath!);
      final duration = await _audioPlayer.getDuration();
      if (duration != null && mounted) {
        setState(() {
          _duration = duration;
          _isLoading = false;
        });
        print('🎵 Duration loaded: $duration');
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔴 Error loading audio: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    // Don't delete cached files - keep them for reuse
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_localFilePath == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await _audioPlayer.resume();
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      print('🔴 Error playing audio: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause Button
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isMe
                    ? Colors.white.withOpacity(0.3)
                    : const Color(0xFF6C63FF).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.isMe ? Colors.white : const Color(0xFF6C63FF),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Waveform and Duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.isMe
                            ? Colors.white.withOpacity(0.3)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: widget.isMe
                              ? Colors.white
                              : const Color(0xFF6C63FF),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Duration
                Text(
                  _isPlaying || _position.inSeconds > 0
                      ? '${_formatDuration(_position)} / ${_formatDuration(_duration)}'
                      : _formatDuration(_duration),
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.isMe
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Mic Icon
          Icon(
            Icons.mic,
            size: 16,
            color: widget.isMe
                ? Colors.white.withOpacity(0.7)
                : Colors.grey[500],
          ),
        ],
      ),
    );
  }
}
