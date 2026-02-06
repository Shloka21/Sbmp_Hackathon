import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../services/auth_service.dart';

/// PIN Setup and Local Auth Screen
class LocalAuthScreen extends StatefulWidget {
  final bool isSetup;
  
  const LocalAuthScreen({super.key, this.isSetup = false});

  @override
  State<LocalAuthScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends State<LocalAuthScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isConfirming = false;
  String? _errorMessage;
  String? _firstPinInput;
  
  bool _showPinPad = true;
  bool _biometricAvailable = false;
  
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _initAuth();
  }
  
  @override
  void dispose() {
    _pinController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _initAuth() async {
    await _authService.init();
    
    if (widget.isSetup) {
      setState(() {
        _showPinPad = true;
      });
    } else {
      final bioEnabled = await _authService.isLocalAuthEnabled();
      if (bioEnabled) {
        setState(() {
          _showPinPad = false;
          _biometricAvailable = true;
        });
        Future.delayed(const Duration(milliseconds: 300), _startBiometric);
      } else {
        setState(() {
          _showPinPad = true;
        });
      }
    }
  }

  Future<void> _startBiometric() async {
    if (mounted) setState(() => _showPinPad = false);
    
    final success = await _authService.authenticateWithBiometrics();
    
    if (success) {
      if (mounted) context.go('/home');
    }
  }

  void _handlePinDigit(String digit) {
    if (_pinController.text.length < 4) {
      setState(() {
        _pinController.text += digit;
        _errorMessage = null;
      });
    }
  }
  
  void _handleBackspace() {
    if (_pinController.text.isNotEmpty) {
      setState(() {
        _pinController.text = _pinController.text.substring(0, _pinController.text.length - 1);
      });
    }
  }
  
  Future<void> _processPinSubmission() async {
    final inputPin = _pinController.text;
    if (inputPin.length < 4) {
      setState(() => _errorMessage = 'Enter 4 digits');
      _shakeError();
      return;
    }
    
    setState(() => _isLoading = true);
    
    if (widget.isSetup) {
      if (!_isConfirming) {
        setState(() {
          _firstPinInput = inputPin;
          _isConfirming = true;
          _pinController.clear();
          _isLoading = false;
        });
      } else {
        if (inputPin == _firstPinInput) {
          await _authService.savePin(inputPin);
          if (mounted) context.go('/language');
        } else {
          setState(() {
            _errorMessage = 'PINs did not match. Try again.';
            _isConfirming = false;
            _pinController.clear();
            _firstPinInput = null;
            _isLoading = false;
          });
          _shakeError();
        }
      }
    } else {
      final isValid = await _authService.verifyPin(inputPin);
      if (isValid) {
        await _authService.updateLastAuth();
        if (mounted) context.go('/home');
      } else {
        setState(() {
          _errorMessage = 'Incorrect PIN';
          _isLoading = false;
          _pinController.clear();
        });
        _shakeError();
      }
    }
  }
  
  void _shakeError() {
    _shakeController.forward().then((_) => _shakeController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
           duration: const Duration(milliseconds: 300),
           child: _showPinPad ? _buildPinPadView() : _buildBiometricView(),
        ),
      ),
    );
  }
  
  Widget _buildBiometricView() {
    return SizedBox(
      key: const ValueKey('BioView'),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_open_rounded, 
              size: 48, 
              color: AppColors.primary
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Welcome Back',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'App Locked for your security',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          
          const Spacer(flex: 3),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _startBiometric,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Unlock with Biometrics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    setState(() => _showPinPad = true);
                  },
                  child: const Text('Use PIN instead'),
                )
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
  
  Widget _buildPinPadView() {
    final title = widget.isSetup
        ? (_isConfirming ? 'Confirm PIN' : 'Set App PIN')
        : 'Enter PIN';
        
    final subtitle = widget.isSetup
        ? (_isConfirming ? 'Re-enter to confirm' : 'Create 4-digit security PIN')
        : 'Enter your 4-digit PIN';

    return Column(
      key: const ValueKey('PinView'),
      children: [
        if (!widget.isSetup && _biometricAvailable)
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _showPinPad = false),
              ),
            ),
          )
        else 
           const SizedBox(height: 56),
           
        const Spacer(),
        
        Icon(Icons.lock, size: 40, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(title, style: AppTypography.headlineMedium),
        Text(subtitle, style: AppTypography.bodyMedium),
        
        const SizedBox(height: 32),
        
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: _buildPinDots(),
            );
          },
        ),
        
        if (_errorMessage != null)
           Padding(
             padding: const EdgeInsets.only(top: 16.0),
             child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
           ),
           
        const Spacer(),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              _buildRow(['1', '2', '3']),
              const SizedBox(height: 24),
              _buildRow(['4', '5', '6']),
              const SizedBox(height: 24),
              _buildRow(['7', '8', '9']),
              const SizedBox(height: 24),
              _buildRow(['', '0', 'del']),
              const SizedBox(height: 32),
              
              if (_pinController.text.length == 4)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _processPinSubmission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Continue'),
                  ),
                )
              else
                 const SizedBox(height: 50),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final filled = index < _pinController.text.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: filled ? AppColors.primary : Colors.grey.shade400,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((key) {
        if (key.isEmpty) return const SizedBox(width: 64, height: 64);
        if (key == 'del') {
          return IconButton(
            onPressed: _handleBackspace,
            icon: const Icon(Icons.backspace_outlined, size: 28),
            style: IconButton.styleFrom(
               fixedSize: const Size(64, 64),
            ),
          );
        }
        return InkWell(
          onTap: () => _handlePinDigit(key),
          borderRadius: BorderRadius.circular(32),
          child: Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
               color: Colors.white,
               shape: BoxShape.circle,
               boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
               ]
            ),
            child: Text(
              key, 
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
            ),
          ),
        );
      }).toList(),
    );
  }
}
