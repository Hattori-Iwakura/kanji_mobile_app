import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// Mini audio player for example sentences
class MiniAudioPlayer extends StatefulWidget {
  final String audioUrl;

  const MiniAudioPlayer({super.key, required this.audioUrl});

  @override
  State<MiniAudioPlayer> createState() => _MiniAudioPlayerState();
}

class _MiniAudioPlayerState extends State<MiniAudioPlayer> {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.stop();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _audioPlayer.play(UrlSource(widget.audioUrl));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _playerState == PlayerState.playing;

    return IconButton(
      onPressed: _isLoading ? null : _play,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.tealAccent,
              ),
            )
          : Icon(
              isPlaying ? Icons.stop_circle : Icons.volume_up,
              color: Colors.tealAccent,
            ),
    );
  }
}
