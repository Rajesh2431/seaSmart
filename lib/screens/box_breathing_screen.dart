import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../l10n/app_localizations.dart';

class BoxBreathingScreen extends StatefulWidget {
  const BoxBreathingScreen({super.key});

  @override
  State<BoxBreathingScreen> createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _pulseController;
  late Animation<double> _radiusAnimation;
  late Animation<double> _pulseAnimation;
  Timer? _sessionTimer;
  Timer? _phaseTimer;

  bool _isRunning = false;
  bool _hasStarted = false;
  late String _statusText;
  int _currentPhaseIndex = 0;
  Duration _remainingTime = Duration.zero;

  // Box breathing specific data
  final List<int> _durations = [4, 4, 4, 4];
  final Color _primaryColor = const Color(0xFF42A5F5);
  final Color _secondaryColor = const Color(0xFFE1F5FE);

  late String _currentQuote;
  late AppLocalizations _localizations;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizations = AppLocalizations.of(context)!;
    _statusText = _localizations.inhale; // Initialize with localized text
    _currentQuote = _getCurrentQuote(); // ✅ safe here
  }

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _radiusAnimation = Tween<double>(begin: 60, end: 180).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _pulseController.dispose();
    _sessionTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _startBreathing(Duration duration) {
    setState(() {
      _remainingTime = duration;
      _hasStarted = true;
      _isRunning = true;
      _currentPhaseIndex = 0;
      _statusText = _localizations.inhale;
    });

    _pulseController.stop();
    _pulseController.reset();
    _startPhaseTimer();

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 1) {
        _stopBreathing();
        timer.cancel();
      } else {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      }
    });
  }

  void _startPhaseTimer() {
    final phaseDuration = _durations[_currentPhaseIndex];
    final currentPhase = _getCurrentPhaseText().toLowerCase();

    _breathController.duration = Duration(seconds: phaseDuration);

    if (currentPhase.contains('inhale')) {
      _breathController.reset();
      _radiusAnimation = Tween<double>(begin: 60, end: 180).animate(
        CurvedAnimation(parent: _breathController, curve: Curves.easeIn),
      );
      _breathController.forward();
    } else if (currentPhase.contains('exhale')) {
      _breathController.reset();
      _radiusAnimation = Tween<double>(begin: 180, end: 60).animate(
        CurvedAnimation(parent: _breathController, curve: Curves.easeOut),
      );
      _breathController.forward();
    } else if (currentPhase.contains('hold')) {
      _breathController.stop();
      final currentRadius = _radiusAnimation.value;

      _pulseController.duration = const Duration(milliseconds: 800);
      _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      );
      _pulseController.repeat(reverse: true);

      _radiusAnimation = Tween<double>(begin: currentRadius, end: currentRadius)
          .animate(_breathController);
    }

    _phaseTimer = Timer(Duration(seconds: phaseDuration), () {
      if (!_isRunning) return;

      setState(() {
        _currentPhaseIndex = (_currentPhaseIndex + 1) % 4;
        _statusText = _getCurrentPhaseText();
      });

      _startPhaseTimer();
    });
  }

  void _stopBreathing() {
    setState(() {
      _isRunning = false;
      _hasStarted = false;
      _statusText = _localizations.sessionComplete;
    });

    _breathController.stop();
    _pulseController.stop();
    _sessionTimer?.cancel();
    _phaseTimer?.cancel();

    _breathController.reset();
    _pulseController.duration = const Duration(seconds: 2);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _radiusAnimation = Tween<double>(begin: 60, end: 180).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  String _getCurrentPhaseText() {
    switch (_currentPhaseIndex) {
      case 0:
        return _localizations.inhale;
      case 1:
        return _localizations.hold;
      case 2:
        return _localizations.exhale;
      case 3:
        return _localizations.hold;
      default:
        return _localizations.inhale;
    }
  }

  String _getCurrentQuote() {
    final quoteIndex = Random().nextInt(5);
    switch (quoteIndex) {
      case 0:
        return _localizations.boxQuote1;
      case 1:
        return _localizations.boxQuote2;
      case 2:
        return _localizations.boxQuote3;
      case 3:
        return _localizations.boxQuote4;
      case 4:
        return _localizations.boxQuote5;
      default:
        return _localizations.boxQuote1;
    }
  }

  Widget _buildRing(double scale, double opacity, Color color) {
    return Container(
      width: _radiusAnimation.value * scale,
      height: _radiusAnimation.value * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity * 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _durationButton(String label, Duration duration, IconData icon) {
    return SizedBox(
      width: 220,
      child: ElevatedButton.icon(
        onPressed: () => _startBreathing(duration),
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: _primaryColor.withOpacity(0.3)),
          ),
          elevation: 8,
          shadowColor: _primaryColor.withOpacity(0.3),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _secondaryColor,
              _primaryColor.withOpacity(0.3),
              _primaryColor.withOpacity(0.5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        if (_hasStarted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer, color: _primaryColor, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDuration(_remainingTime),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: _primaryColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            _localizations.boxBreathing,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.0,
                            ),
                          ),
                        const Spacer(),
                        const SizedBox(width: 56),
                      ],
                    ),
                  ),

                  // Main content
                  Expanded(
                    child: !_hasStarted ? _buildDurationPanel() : _buildBreathingAnimation(),
                  ),

                  // Footer
                  SizedBox(
                    height: _hasStarted ? 80 : 60,
                    child: _buildFooter(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDurationPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.crop_square, size: 40, color: _primaryColor),
                const SizedBox(height: 12),
                Text(
                  _localizations.boxBreathing,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _localizations.boxBreathingDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _localizations.chooseSessionDuration,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              _durationButton(_localizations.oneMinute, const Duration(minutes: 1), Icons.looks_one),
              const SizedBox(height: 12),
              _durationButton(_localizations.threeMinutes, const Duration(minutes: 3), Icons.looks_3),
              const SizedBox(height: 12),
              _durationButton(_localizations.fiveMinutes, const Duration(minutes: 5), Icons.looks_5),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBreathingAnimation() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                _statusText,
                style: TextStyle(
                  fontSize: 22,
                  color: _primaryColor,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: Listenable.merge([_radiusAnimation, _pulseAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildRing(2.8, 0.02, _primaryColor),
                      _buildRing(2.4, 0.04, _primaryColor),
                      _buildRing(2.0, 0.06, _primaryColor),
                      _buildRing(1.6, 0.10, _primaryColor),
                      _buildRing(1.3, 0.15, _primaryColor),
                      Container(
                        width: _radiusAnimation.value,
                        height: _radiusAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _primaryColor.withOpacity(0.95),
                              _primaryColor.withOpacity(0.7),
                              _primaryColor.withOpacity(0.4),
                              _primaryColor.withOpacity(0.15),
                              _primaryColor.withOpacity(0.05),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.5),
                              blurRadius: _radiusAnimation.value * 0.3,
                              spreadRadius: _radiusAnimation.value * 0.1,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.95),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Icon(Icons.crop_square, color: _primaryColor, size: 30),
                      ),
                      if (_statusText.toLowerCase().contains('hold'))
                        Container(
                          width: _radiusAnimation.value + 20,
                          height: _radiusAnimation.value + 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _primaryColor.withOpacity(0.6),
                              width: 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _localizations.boxPhaseOf(_currentPhaseIndex + 1),
                style: TextStyle(
                  fontSize: 13,
                  color: _primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_hasStarted) ...[
            ElevatedButton.icon(
              onPressed: _stopBreathing,
              icon: const Icon(Icons.stop, size: 16),
              label: Text(_localizations.stopSession, style: const TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                foregroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                minimumSize: const Size(0, 36),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: Center(
              child: Text(
                _currentQuote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
