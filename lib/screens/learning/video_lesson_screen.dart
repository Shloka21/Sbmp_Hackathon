import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/video_lesson.dart';
import '../../providers/user_provider.dart';
import '../../widgets/learning/video_lesson_player.dart';

/// Video Lesson Detail Screen
class VideoLessonScreen extends StatefulWidget {
  final String lessonId;

  const VideoLessonScreen({super.key, required this.lessonId});

  @override
  State<VideoLessonScreen> createState() => _VideoLessonScreenState();
}

class _VideoLessonScreenState extends State<VideoLessonScreen> {
  VideoLesson? _lesson;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _lesson = VideoLessonsData.getById(widget.lessonId);
  }

  void _onLessonComplete() {
    setState(() => _isCompleted = true);
    HapticFeedback.mediumImpact();

    // Show completion dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎉', textAlign: TextAlign.center, style: TextStyle(fontSize: 48)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.read<UserProvider>().language == 'hi'
                  ? 'बधाई हो! पाठ पूरा हुआ!'
                  : 'Congratulations! Lesson Complete!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '+${_lesson?.xpReward ?? 0} XP',
              style: TextStyle(
                color: Colors.green.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text(
              context.read<UserProvider>().language == 'hi' ? 'वापस जाएं' : 'Go Back',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';

    if (_lesson == null) {
      return Scaffold(
        appBar: AppBar(title: Text(isHindi ? 'पाठ' : 'Lesson')),
        body: Center(
          child: Text(isHindi ? 'पाठ नहीं मिला' : 'Lesson not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          _lesson!.getTitle(userProvider.language),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (_isCompleted)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.check_circle, color: Colors.greenAccent),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player
            VideoLessonPlayer(
              lesson: _lesson!,
              languageCode: userProvider.language,
              onComplete: _onLessonComplete,
            ),

            // Lesson Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _lesson!.getTitle(userProvider.language),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    _lesson!.getDescription(userProvider.language),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    children: [
                      _buildStatChip(
                        icon: Icons.timer,
                        label: '${(_lesson!.durationSeconds / 60).ceil()} min',
                      ),
                      const SizedBox(width: 12),
                      _buildStatChip(
                        icon: Icons.star,
                        label: '+${_lesson!.xpReward} XP',
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 12),
                      _buildStatChip(
                        icon: Icons.language,
                        label: '${_lesson!.audioTracks.length} ${isHindi ? 'भाषाएं' : 'languages'}',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Available Languages
                  Text(
                    isHindi ? '🌐 उपलब्ध भाषाएं' : '🌐 Available Languages',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _lesson!.audioTracks.keys.map((langCode) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: langCode == userProvider.language
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          SupportedLanguages.getName(langCode),
                          style: TextStyle(
                            color: langCode == userProvider.language
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
