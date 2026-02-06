import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/video_lesson.dart';

/// Subtitle data structure
class Subtitle {
  final Duration start;
  final Duration end;
  final String text;

  Subtitle({required this.start, required this.end, required this.text});
}

/// Multilingual Video Player Widget with Fullscreen Support
class VideoLessonPlayer extends StatefulWidget {
  final VideoLesson lesson;
  final String languageCode;
  final VoidCallback? onComplete;

  const VideoLessonPlayer({
    super.key,
    required this.lesson,
    required this.languageCode,
    this.onComplete,
  });

  @override
  State<VideoLessonPlayer> createState() => _VideoLessonPlayerState();
}

class _VideoLessonPlayerState extends State<VideoLessonPlayer> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  List<Subtitle> _subtitles = [];
  String _currentSubtitle = '';
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String _selectedLanguage = 'en';
  bool _hasCustomAudio = false;

  // Available languages for display
  final List<String> _availableLanguages = ['en', 'hi', 'mr', 'te', 'kn', 'bn'];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.languageCode;
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _videoController = VideoPlayerController.asset(widget.lesson.videoPath);
      await _videoController!.initialize();
      
      _duration = _videoController!.value.duration;

      _audioPlayer = AudioPlayer();
      await _tryLoadAudio(_selectedLanguage);

      await _loadSubtitles();

      _videoController!.addListener(_onVideoUpdate);

      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  Future<void> _tryLoadAudio(String langCode) async {
    final audioPath = widget.lesson.getAudioTrack(langCode);
    
    if (audioPath != null) {
      try {
        await _audioPlayer!.setAsset(audioPath);
        await _videoController!.setVolume(0.0);
        _hasCustomAudio = true;
        debugPrint('Loaded audio for $langCode');
      } catch (e) {
        debugPrint('Audio not found for $langCode, using video audio');
        await _videoController!.setVolume(1.0);
        _hasCustomAudio = false;
      }
    } else {
      await _videoController!.setVolume(1.0);
      _hasCustomAudio = false;
    }
  }

  Future<void> _loadSubtitles() async {
    final subtitlePath = widget.lesson.getSubtitles(_selectedLanguage);
    if (subtitlePath == null) return;

    try {
      final content = await rootBundle.loadString(subtitlePath);
      _subtitles = _parseSrt(content);
    } catch (e) {
      debugPrint('Subtitles not available');
    }
  }

  List<Subtitle> _parseSrt(String content) {
    final List<Subtitle> subtitles = [];
    final blocks = content.trim().split(RegExp(r'\n\n+'));

    for (final block in blocks) {
      final lines = block.split('\n');
      if (lines.length >= 3) {
        final timeLine = lines[1];
        final timeMatch = RegExp(
          r'(\d{2}):(\d{2}):(\d{2}),(\d{3})\s*-->\s*(\d{2}):(\d{2}):(\d{2}),(\d{3})',
        ).firstMatch(timeLine);

        if (timeMatch != null) {
          final start = Duration(
            hours: int.parse(timeMatch.group(1)!),
            minutes: int.parse(timeMatch.group(2)!),
            seconds: int.parse(timeMatch.group(3)!),
            milliseconds: int.parse(timeMatch.group(4)!),
          );
          final end = Duration(
            hours: int.parse(timeMatch.group(5)!),
            minutes: int.parse(timeMatch.group(6)!),
            seconds: int.parse(timeMatch.group(7)!),
            milliseconds: int.parse(timeMatch.group(8)!),
          );
          final text = lines.sublist(2).join('\n');
          subtitles.add(Subtitle(start: start, end: end, text: text));
        }
      }
    }
    return subtitles;
  }

  void _onVideoUpdate() {
    if (!mounted || _videoController == null) return;

    final position = _videoController!.value.position;
    if (_position.inSeconds != position.inSeconds) {
      setState(() => _position = position);
    }

    if (position >= _duration && _duration.inSeconds > 0) {
      widget.onComplete?.call();
    }

    for (final sub in _subtitles) {
      if (position >= sub.start && position <= sub.end) {
        if (_currentSubtitle != sub.text) {
          setState(() => _currentSubtitle = sub.text);
        }
        return;
      }
    }
    if (_currentSubtitle.isNotEmpty) {
      setState(() => _currentSubtitle = '');
    }
  }

  Future<void> _togglePlayPause() async {
    if (_videoController == null) return;

    HapticFeedback.lightImpact();

    if (_isPlaying) {
      await _videoController!.pause();
      if (_hasCustomAudio) await _audioPlayer?.pause();
    } else {
      await _videoController!.play();
      if (_hasCustomAudio) await _audioPlayer?.play();
    }

    setState(() => _isPlaying = !_isPlaying);
  }

  Future<void> _seekTo(Duration position) async {
    await _videoController?.seekTo(position);
    if (_hasCustomAudio) await _audioPlayer?.seek(position);
  }

  Future<void> _changeLanguage(String langCode) async {
    if (langCode == _selectedLanguage) return;

    // Get video state BEFORE any changes
    final isVideoPlaying = _videoController?.value.isPlaying ?? false;
    final videoPosition = _videoController?.value.position ?? Duration.zero;
    
    setState(() => _selectedLanguage = langCode);

    // Stop old audio if playing
    try {
      await _audioPlayer?.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }

    // Load new audio
    await _tryLoadAudio(langCode);
    await _loadSubtitles();

    // Sync new audio to video position and play if video is playing
    if (_hasCustomAudio && _audioPlayer != null) {
      try {
        await _audioPlayer!.seek(videoPosition);
        if (isVideoPlaying) {
          await _audioPlayer!.play();
        }
      } catch (e) {
        debugPrint('Error syncing audio: $e');
      }
    }

    // Show feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔊 ${SupportedLanguages.getName(langCode)}'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openFullscreen() {
    HapticFeedback.mediumImpact();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenVideoPlayer(
          videoController: _videoController!,
          audioPlayer: _audioPlayer,
          hasCustomAudio: _hasCustomAudio,
          position: _position,
          duration: _duration,
          isPlaying: _isPlaying,
          selectedLanguage: _selectedLanguage,
          availableLanguages: _availableLanguages,
          currentSubtitle: _currentSubtitle,
          onSeek: _seekTo,
          onTogglePlay: _togglePlayPause,
          onChangeLanguage: _changeLanguage,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        // Video
        GestureDetector(
          onTap: () => setState(() => _showControls = !_showControls),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),

              // Play/Pause overlay
              if (_showControls)
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),

              // (Fullscreen button moved to controls bar only)
            ],
          ),
        ),

        // Subtitles
        if (_currentSubtitle.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.black87,
            child: Text(
              _currentSubtitle,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),

        // Controls
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
          child: Column(
            children: [
              // Progress Bar
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble()),
                  max: _duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                  onChanged: (value) => _seekTo(Duration(milliseconds: value.toInt())),
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),

              // Controls Row
              Row(
                children: [
                  Text(
                    '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),

                  const Spacer(),

                  // Language Selector
                  PopupMenuButton<String>(
                    initialValue: _selectedLanguage,
                    onSelected: _changeLanguage,
                    tooltip: 'Change language',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            SupportedLanguages.getName(_selectedLanguage),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 16),
                        ],
                      ),
                    ),
                    itemBuilder: (context) {
                      return _availableLanguages.map((langCode) {
                        final isSelected = langCode == _selectedLanguage;
                        return PopupMenuItem<String>(
                          value: langCode,
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle : Icons.circle_outlined,
                                size: 18,
                                color: isSelected ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                SupportedLanguages.getName(langCode),
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              if (langCode == 'en')
                                Text(
                                  ' (Original)',
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                  ),

                  const SizedBox(width: 8),

                  // Fullscreen button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen, size: 24),
                      onPressed: _openFullscreen,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }
}

/// Fullscreen Video Player (pushed as a new route)
class _FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController videoController;
  final AudioPlayer? audioPlayer;
  final bool hasCustomAudio;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final String selectedLanguage;
  final List<String> availableLanguages;
  final String currentSubtitle;
  final Function(Duration) onSeek;
  final VoidCallback onTogglePlay;
  final Function(String) onChangeLanguage;

  const _FullscreenVideoPlayer({
    required this.videoController,
    required this.audioPlayer,
    required this.hasCustomAudio,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.selectedLanguage,
    required this.availableLanguages,
    required this.currentSubtitle,
    required this.onSeek,
    required this.onTogglePlay,
    required this.onChangeLanguage,
  });

  @override
  State<_FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<_FullscreenVideoPlayer> {
  bool _showControls = true;
  late Duration _position;
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();
    _position = widget.position;
    _isPlaying = widget.isPlaying;
    
    // Enter fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Listen for position updates
    widget.videoController.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) {
      setState(() {
        _position = widget.videoController.value.position;
        _isPlaying = widget.videoController.value.isPlaying;
      });
    }
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Navigator.of(context).pop();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video
            Center(
              child: AspectRatio(
                aspectRatio: widget.videoController.value.aspectRatio,
                child: VideoPlayer(widget.videoController),
              ),
            ),

            // Controls overlay
            if (_showControls)
              Container(
                color: Colors.black38,
                child: Column(
                  children: [
                    // Top bar
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                              onPressed: _exitFullscreen,
                            ),
                            const Spacer(),
                            // Language selector
                            PopupMenuButton<String>(
                              initialValue: widget.selectedLanguage,
                              onSelected: widget.onChangeLanguage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.language, color: Colors.white, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      SupportedLanguages.getName(widget.selectedLanguage),
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              itemBuilder: (context) {
                                return widget.availableLanguages.map((langCode) {
                                  return PopupMenuItem<String>(
                                    value: langCode,
                                    child: Text(SupportedLanguages.getName(langCode)),
                                  );
                                }).toList();
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 28),
                              onPressed: _exitFullscreen,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Center play button
                    Expanded(
                      child: Center(
                        child: IconButton(
                          iconSize: 80,
                          icon: Icon(
                            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: Colors.white,
                          ),
                          onPressed: widget.onTogglePlay,
                        ),
                      ),
                    ),

                    // Bottom progress bar
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                ),
                                child: Slider(
                                  value: _position.inMilliseconds.toDouble().clamp(0, widget.duration.inMilliseconds.toDouble()),
                                  max: widget.duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                                  onChanged: (value) => widget.onSeek(Duration(milliseconds: value.toInt())),
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white38,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _formatDuration(widget.duration),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Subtitles
            if (widget.currentSubtitle.isNotEmpty && _showControls)
              Positioned(
                bottom: 100,
                left: 40,
                right: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.currentSubtitle,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.videoController.removeListener(_onUpdate);
    // Restore orientation
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }
}
