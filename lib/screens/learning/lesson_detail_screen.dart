import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../config/theme.dart';
import '../../data/lesson_data.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/widgets.dart';

/// Lesson Detail Screen - Interactive learning content with MCQs
class LessonDetailScreen extends StatefulWidget {
  final String lessonId;

  const LessonDetailScreen({super.key, required this.lessonId});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int _currentStep = 0;
  int? _selectedOption;
  bool _answered = false;
  int _correctAnswers = 0;
  int _currentMcqIndex = 0;
  bool _quizMode = false;
  
  Map<String, dynamic>? _lesson;
  List<Map<String, dynamic>> _contentSteps = [];
  List<Map<String, dynamic>> _mcqs = [];
  
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _loadLesson();
    _initializeVideo();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  void _loadLesson() {
    _lesson = LessonData.getLessonById(widget.lessonId);
    if (_lesson != null) {
      // Convert content to list of steps
      final content = _lesson!['content'] as List? ?? [];
      _contentSteps = content.map((c) => c as Map<String, dynamic>).toList();
      
      // Load MCQs
      final mcqs = _lesson!['mcqs'] as List? ?? [];
      _mcqs = mcqs.map((m) => m as Map<String, dynamic>).toList();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _videoController!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  Future<void> _initializeVideo() async {
    if (_lesson != null && _lesson!.containsKey('videoPath')) {
      final videoPath = _lesson!['videoPath'] as String;
      _videoController = VideoPlayerController.asset(videoPath);
      
      try {
        await _videoController!.initialize();
        setState(() {
          _isVideoInitialized = true;
        });
      } catch (e) {
        debugPrint('Error initializing video: $e');
      }
    }
  }

  int get _totalSteps => _contentSteps.length + (_mcqs.isNotEmpty ? 1 : 0) + 1; // +1 for completion

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';

    if (_lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(isHindi ? 'पाठ नहीं मिला' : 'Lesson not found'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(isHindi ? 'वापस जाएं' : 'Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_totalSteps, (index) {
            final isCompleted = index < _currentStep;
            final isCurrent = index == _currentStep;
            return Container(
              width: isCurrent ? 28 : 20,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success
                    : isCurrent
                        ? AppColors.primaryAccent
                        : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              isHindi ? 'बाद में' : 'Later',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _buildCurrentStep(isHindi),
            ),
          ),
          // Bottom navigation
          Container(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
              top: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: _buildBottomButton(isHindi, userProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(bool isHindi) {
    // Content steps
    if (_currentStep < _contentSteps.length) {
      return _buildContentStep(_contentSteps[_currentStep], isHindi);
    }
    
    // Quiz step
    if (_quizMode && _currentMcqIndex < _mcqs.length) {
      return _buildQuizStep(_mcqs[_currentMcqIndex], isHindi);
    }
    
    // If we haven't started quiz mode yet but have MCQs
    if (_currentStep == _contentSteps.length && _mcqs.isNotEmpty && !_quizMode) {
      return _buildQuizIntro(isHindi);
    }
    
    // Completion step
    return _buildCompletionStep(isHindi);
  }

  Widget _buildContentStep(Map<String, dynamic> step, bool isHindi) {
    final text = (isHindi ? step['hi'] : step['en']) as String? ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video Player (Only on first step if available)
        if (_currentStep == 0 && _isVideoInitialized && _videoController != null)
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_videoController!),
                  
                  // Touch overlay to toggle controls
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showControls = !_showControls;
                        if (_showControls && _videoController!.value.isPlaying) {
                          _startHideTimer();
                        }
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),

                  // Controls Overlay
                  IgnorePointer(
                    ignoring: !_showControls,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _showControls ? 1.0 : 0.0,
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_videoController!.value.isPlaying) {
                                  _videoController!.pause();
                                  _hideTimer?.cancel(); // Keep controls visible when paused
                                  _showControls = true;
                                } else {
                                  _videoController!.play();
                                  _startHideTimer(); // Auto hide when playing
                                  _showControls = true;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                _videoController!.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // Lesson Icon (Only show if video is NOT shown)
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  _lesson!['icon'] ?? '📚',
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
          
        const SizedBox(height: AppSpacing.xl),
        
        // Step indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_currentStep + 1} / ${_contentSteps.length}',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Content with markdown-like rendering
        _buildMarkdownContent(text),
      ],
    );
  }

  Widget _buildMarkdownContent(String text) {
    final lines = text.split('\n');
    final widgets = <Widget>[];
    
    for (final line in lines) {
      if (line.startsWith('## ')) {
        // Heading
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(
            line.substring(3),
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ));
      } else if (line.startsWith('**') && line.endsWith('**')) {
        // Bold paragraph
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            line.replaceAll('**', ''),
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ));
      } else if (line.startsWith('- ') || line.startsWith('• ')) {
        // Bullet point
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  line.substring(2),
                  style: AppTypography.bodyLarge.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        ));
      } else if (line.trim().isNotEmpty) {
        // Regular paragraph
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            line.replaceAll('**', ''),
            style: AppTypography.bodyLarge.copyWith(height: 1.6),
          ),
        ));
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget _buildQuizIntro(bool isHindi) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text('🎯', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 24),
        Text(
          isHindi ? 'क्विज़ टाइम!' : 'Quiz Time!',
          style: AppTypography.headlineLarge,
        ),
        const SizedBox(height: 16),
        Text(
          isHindi 
              ? 'अब देखते हैं आपने क्या सीखा। ${_mcqs.length} सवालों के जवाब दें!'
              : 'Let\'s see what you learned. Answer ${_mcqs.length} questions!',
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('✓', style: TextStyle(fontSize: 24, color: AppColors.success)),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? 'गलत जवाब पर नया सवाल' : 'Wrong answer? Get a new question',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    '+${_lesson!['xpReward']} XP',
                    style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizStep(Map<String, dynamic> mcq, bool isHindi) {
    final question = isHindi ? mcq['questionHi'] : mcq['question'];
    final options = mcq['options'] as List;
    final correctIndex = mcq['correct'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            _answered 
                ? (_selectedOption == correctIndex ? '🎉' : '🤔')
                : '❓',
            style: const TextStyle(fontSize: 64),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Question counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isHindi 
                ? 'सवाल ${_currentMcqIndex + 1}/${_mcqs.length}'
                : 'Question ${_currentMcqIndex + 1}/${_mcqs.length}',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        
        Text(
          question,
          style: AppTypography.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xl),
        
        // Options
        ...List.generate(options.length, (index) {
          final isSelected = _selectedOption == index;
          final isCorrect = index == correctIndex;

          Color? bgColor;
          Color? borderColor;

          if (_answered) {
            if (isCorrect) {
              bgColor = AppColors.success.withOpacity(0.15);
              borderColor = AppColors.success;
            } else if (isSelected && !isCorrect) {
              bgColor = AppColors.error.withOpacity(0.15);
              borderColor = AppColors.error;
            }
          } else if (isSelected) {
            bgColor = AppColors.primary.withOpacity(0.1);
            borderColor = AppColors.primary;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: _answered ? null : () {
                HapticFeedback.selectionClick();
                setState(() => _selectedOption = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor ?? Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected && !_answered
                            ? AppColors.primary
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isSelected && !_answered
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        options[index],
                        style: AppTypography.titleMedium,
                      ),
                    ),
                    if (_answered && isCorrect)
                      const Icon(Icons.check_circle, color: AppColors.success, size: 28),
                    if (_answered && isSelected && !isCorrect)
                      const Icon(Icons.cancel, color: AppColors.error, size: 28),
                  ],
                ),
              ),
            ),
          );
        }),
        
        // Feedback
        if (_answered)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedOption == correctIndex
                  ? AppColors.success.withOpacity(0.15)
                  : AppColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  _selectedOption == correctIndex ? '🎉' : '💪',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedOption == correctIndex
                        ? (isHindi ? 'बहुत बढ़िया! सही जवाब!' : 'Excellent! Correct!')
                        : (isHindi 
                            ? 'कोई बात नहीं! आगे बढ़ो और सीखो!' 
                            : 'No worries! Keep learning!'),
                    style: AppTypography.titleMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCompletionStep(bool isHindi) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text('🎉', style: TextStyle(fontSize: 100)),
        const SizedBox(height: 24),
        Text(
          isHindi ? 'बधाई हो!' : 'Congratulations!',
          style: AppTypography.headlineLarge,
        ),
        const SizedBox(height: 16),
        Text(
          isHindi 
              ? 'आपने यह पाठ पूरा कर लिया!'
              : 'You completed this lesson!',
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Stats
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.success, width: 2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Text(
                    '+${_lesson!['xpReward']} XP',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (_mcqs.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  isHindi 
                      ? 'क्विज़ स्कोर: $_correctAnswers/${_mcqs.length}'
                      : 'Quiz Score: $_correctAnswers/${_mcqs.length}',
                  style: AppTypography.titleMedium,
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        Text(
          isHindi 
              ? '🔓 अगला पाठ अनलॉक हो गया!'
              : '🔓 Next lesson unlocked!',
          style: AppTypography.titleMedium.copyWith(color: AppColors.success),
        ),
      ],
    );
  }

  Widget _buildBottomButton(bool isHindi, UserProvider userProvider) {
    // Quiz intro - start quiz
    if (_currentStep == _contentSteps.length && _mcqs.isNotEmpty && !_quizMode) {
      return PrimaryButton(
        text: isHindi ? 'क्विज़ शुरू करें 🎯' : 'Start Quiz 🎯',
        onPressed: () {
          HapticFeedback.mediumImpact();
          setState(() {
            _quizMode = true;
            _currentMcqIndex = 0;
          });
        },
      );
    }
    
    // Quiz mode - check answer
    if (_quizMode && _currentMcqIndex < _mcqs.length && !_answered) {
      return PrimaryButton(
        text: isHindi ? 'जवाब चेक करें' : 'Check Answer',
        onPressed: _selectedOption == null ? () {} : () {
          HapticFeedback.mediumImpact();
          final correctIndex = _mcqs[_currentMcqIndex]['correct'] as int;
          if (_selectedOption == correctIndex) {
            _correctAnswers++;
          }
          setState(() => _answered = true);
        },
      );
    }
    
    // Quiz mode - next question or complete
    if (_quizMode && _answered) {
      final isLastQuestion = _currentMcqIndex >= _mcqs.length - 1;
      return PrimaryButton(
        text: isLastQuestion
            ? (isHindi ? 'पूरा करें 🎉' : 'Complete 🎉')
            : (isHindi ? 'अगला सवाल' : 'Next Question'),
        onPressed: () {
          HapticFeedback.lightImpact();
          if (isLastQuestion) {
            setState(() {
              _currentStep = _contentSteps.length + 1; // Go to completion
              _quizMode = false;
            });
          } else {
            setState(() {
              _currentMcqIndex++;
              _selectedOption = null;
              _answered = false;
            });
          }
        },
      );
    }
    
    // Content steps - continue
    if (_currentStep < _contentSteps.length) {
      return PrimaryButton(
        text: isHindi ? 'आगे बढ़ें' : 'Continue',
        onPressed: () {
          HapticFeedback.lightImpact();
          setState(() => _currentStep++);
        },
      );
    }
    
    // Completion - finish and mark complete
    return PrimaryButton(
      text: isHindi ? 'वापस जाएं ✓' : 'Finish ✓',
      onPressed: () async {
        HapticFeedback.heavyImpact();
        
        // Mark lesson as complete
        await userProvider.markLessonComplete(
          widget.lessonId,
          _lesson!['xpReward'] as int,
        );
        
        if (mounted) {
          context.pop();
        }
      },
    );
  }
}
