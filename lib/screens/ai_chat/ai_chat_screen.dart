import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../providers/user_provider.dart';
import '../../services/groq_ai_service.dart';
import '../../services/offline_ai_brain.dart';

/// Agentic AI Chat Screen - Premium UI with Sathi Assistant
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isOnline = true;
  bool _showSuggestions = true;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _checkConnectivity();
    _addWelcomeMessage();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  void _addWelcomeMessage() {
    final userProvider = context.read<UserProvider>();
    final isHindi = userProvider.language == 'hi';
    final name = userProvider.userName;
    
    final greeting = isHindi
        ? 'नमस्ते${name.isNotEmpty ? ' $name' : ''}! 🐻\n\nमैं साथी, आपका AI वित्तीय सहायक। मुझसे कुछ भी पूछें - बचत, लोन, सरकारी योजनाएं, या व्यापार के बारे में!'
        : 'Hey${name.isNotEmpty ? ' $name' : ''}! 🐻\n\nI\'m Sathi, your AI financial assistant. Ask me anything about savings, loans, govt schemes, or starting a business!';
    
    _messages.add(ChatMessage(
      text: greeting,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  List<String> _getSuggestions(bool isHindi) {
    if (isHindi) {
      return [
        '💰 बचत कैसे करूं?',
        '🏛️ सरकारी योजनाएं',
        '🏦 EMI कैलकुलेट करो',
        '🚀 व्यापार शुरू करूं?',
        '📈 पैसा कहां लगाऊं?',
      ];
    }
    return [
      '💰 How to save money?',
      '🏛️ Government schemes',
      '🏦 Calculate my EMI',
      '🚀 Business ideas?',
      '📈 Where to invest?',
    ];
  }

  Future<void> _sendMessage([String? preset]) async {
    final text = preset ?? _messageController.text.trim();
    if (text.isEmpty) return;

    final userProvider = context.read<UserProvider>();

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isLoading = true;
      _showSuggestions = false;
    });

    _scrollToBottom();

    String responseText;
    String? toolUsed;
    
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity != ConnectivityResult.none;

    if (isOnline && GroqAIService.hasApiKey) {
      try {
        final response = await GroqAIService.getResponse(
          message: text,
          language: userProvider.language,
          occupation: userProvider.occupation,
          history: _messages
              .where((m) => !m.isUser || _messages.indexOf(m) > _messages.length - 8)
              .map((m) => <String, dynamic>{
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              })
              .toList(),
        );
        responseText = response.message;
        toolUsed = response.toolUsed;
      } catch (e) {
        responseText = OfflineAiBrain.getResponse(
          message: text,
          language: userProvider.language,
          userOccupation: userProvider.occupation,
        );
      }
    } else {
      responseText = OfflineAiBrain.getResponse(
        message: text,
        language: userProvider.language,
        userOccupation: userProvider.occupation,
      );
    }

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
          toolUsed: toolUsed,
        ));
        _isLoading = false;
      });
      _scrollToBottom();
      
      userProvider.addXP(5);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _addWelcomeMessage();
      _showSuggestions = true;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';
    final suggestions = _getSuggestions(isHindi);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(isHindi),
      body: Column(
        children: [
          if (!_isOnline)
            _buildStatusBanner(isHindi),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20), // Increased padding
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index], isHindi);
              },
            ),
          ),
          
          if (_showSuggestions && !_isLoading)
            _buildSuggestionChips(suggestions),

          _buildInputArea(isHindi),
        ],
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar(bool isHindi) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Text('🐻', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHindi ? 'साथी AI' : 'Sathi AI',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _isOnline ? Colors.greenAccent : Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isOnline 
                        ? (isHindi ? 'ऑनलाइन' : 'Online')
                        : (isHindi ? 'ऑफलाइन' : 'Offline'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          tooltip: 'Clear Chat',
          onPressed: _clearChat,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
  
  Widget _buildStatusBanner(bool isHindi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 14, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          Text(
            isHindi ? 'ऑफलाइन मोड' : 'Offline Mode',
            style: TextStyle(
              color: Colors.orange.shade800,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestionChips(List<String> suggestions) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(suggestions[index]),
              labelStyle: const TextStyle(fontSize: 12, color: AppColors.primary),
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black12,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () => _sendMessage(suggestions[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isHindi) {
    final isUser = message.isUser;
    final time = DateFormat('jm').format(message.timestamp);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI Avatar (Left)
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: const Center(child: Text('🐻', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 8),
          ],

          // Message Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(24),
                      topRight: const Radius.circular(24),
                      bottomLeft: Radius.circular(isUser ? 24 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      if (message.toolUsed != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt, size: 12, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                _getToolLabel(message.toolUsed!, isHindi),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // User Avatar (Right)
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: ApiKeyIcon(isUser), // Using custom widget or just icon
            ),
          ],
        ],
      ),
    );
  }

  Widget ApiKeyIcon(bool isUser) {
    if (isUser) {
      return const Icon(Icons.person_rounded, size: 18, color: AppColors.primary);
    }
    return const SizedBox();
  }
  
  String _getToolLabel(String tool, bool isHindi) {
    final labels = {
      'get_savings_advice': isHindi ? 'बचत सलाह' : 'Savings Advice',
      'search_government_schemes': isHindi ? 'योजना खोज' : 'Scheme Search',
      'calculate_loan_emi': isHindi ? 'EMI गणना' : 'EMI Calculator',
      'get_investment_suggestion': isHindi ? 'निवेश सुझाव' : 'Investment Tip',
      'get_business_idea': isHindi ? 'व्यापार आइडिया' : 'Business Idea',
    };
    return labels[tool] ?? tool;
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 40),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => _buildPulsingDot(index)),
        ),
      ),
    );
  }

  Widget _buildPulsingDot(int index) {
    return Padding(
      padding: EdgeInsets.only(left: index > 0 ? 6 : 0),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.2).animate(
          CurvedAnimation(
            parent: _pulseController,
            curve: Interval(index * 0.2, 0.6 + index * 0.2, curve: Curves.easeInOut),
          ),
        ),
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isHindi) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: isHindi ? 'कुछ पूछें...' : 'Ask something...',
                  hintStyle: TextStyle(color: AppColors.textLight.withValues(alpha: 0.7)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  suffixIcon: _isLoading ? null : IconButton(
                    icon: Icon(Icons.mic_rounded, color: AppColors.primary.withValues(alpha: 0.6)),
                    onPressed: () {}, // Future voice feature
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
                onTap: () {
                  setState(() => _showSuggestions = false);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isLoading ? null : () => _sendMessage(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: _isLoading 
                    ? LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400])
                    : AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  if (!_isLoading)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Icon(
                _isLoading ? Icons.hourglass_top_rounded : Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? toolUsed;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.toolUsed,
  });
}
