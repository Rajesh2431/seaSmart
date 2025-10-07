import 'dart:io';
import 'dart:async';
import 'package:SeaSmart/screens/goal_set.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/user_profile_service.dart';
import '../services/mood_service.dart';
import '../services/soar_card_service.dart';
import '../services/goal_service.dart';
import '../models/soar_card_answer.dart';
import 'breathing_timer.dart';
import 'tap_the_calm_game.dart';
import 'memory_game.dart';
import 'journal_screen.dart';
import 'mood_analytics_screen.dart';
import 'user_profile_screen.dart';
import 'chat_screen.dart';
import 'setting_screen.dart';
import 'academy.dart';
import 'soar_card_analysis.dart';
import '../widgets/avatar_showcase_widget.dart';
import '../widgets/tour_skip_button.dart';
import '../services/guided_tour_service.dart';
import '../services/avatar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class GrowScreen extends StatefulWidget {
  const GrowScreen({super.key});

  @override
  State<GrowScreen> createState() => _GrowScreenState();

  // Static getters for tour access
  static TabController? get currentTabController =>
      _GrowScreenState._currentInstance?._tabController;
  static ScrollController? get currentScrollController =>
      _GrowScreenState._currentInstance?._scrollController;
}

class _MoodIndicator extends StatelessWidget {
  final Color color;
  final bool isActive;

  const _MoodIndicator({required this.color, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? color : color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("journal")));
}

class CertificatePage extends StatelessWidget {
  const CertificatePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("certificates screen")));
}

class MoodPage extends StatelessWidget {
  const MoodPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("mood analytics screen")));
}

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Progress Report screen")));
}

class HorizontalCalendar extends StatefulWidget {
  const HorizontalCalendar({super.key});

  @override
  State<HorizontalCalendar> createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalCalendar>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  Set<String> loginDates = {}; // Stores dates when user logged in
  int currentStreak = 0;
  bool showConfetti = false;
  AnimationController? _confettiController;
  final List<Confetti> _confettiList = [];

  // Motivational quotes
  final List<String> motivationalQuotes = [
    "You're doing amazing! Keep it up! 🌟",
    "Every day is a new opportunity to grow! 🚀",
    "Your consistency is inspiring! 💪",
    "You're building incredible habits! ✨",
    "Keep shining, superstar! ⭐",
    "Your dedication is paying off! 🎯",
    "Progress, not perfection! 🌈",
    "You're unstoppable! 🔥",
    "Believe in yourself! You're doing great! 💫",
    "Small steps lead to big changes! 🌺",
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addListener(() {
            if (mounted) setState(() {});
          });
    _loadLoginData();
    _markTodayAsLogin();
  }

  @override
  void dispose() {
    _confettiController?.dispose();
    super.dispose();
  }

  // Load login dates from SharedPreferences
  Future<void> _loadLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDates = prefs.getStringList('login_dates') ?? [];

    if (mounted) {
      setState(() {
        loginDates = savedDates.toSet();
        currentStreak = _calculateStreak();
      });
    }
  }

  // Mark today as a login day
  Future<void> _markTodayAsLogin() async {
    final today = DateTime.now();
    final todayString = _formatDate(today);

    if (!loginDates.contains(todayString)) {
      loginDates.add(todayString);
      await _saveLoginDates();

      if (mounted) {
        setState(() {
          currentStreak = _calculateStreak();
        });
      }
    }
  }

  // Save login dates to SharedPreferences
  Future<void> _saveLoginDates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('login_dates', loginDates.toList());
  }

  // Format date as string for comparison
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Check if a date has a login
  bool _hasLogin(DateTime date) {
    return loginDates.contains(_formatDate(date));
  }

  // Calculate current streak
  int _calculateStreak() {
    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (_hasLogin(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // Trigger celebration overlay
  void _triggerCelebration() {
    if (showConfetti || _confettiController == null) return;

    // Show full-screen overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => _CelebrationOverlay(
        quote: motivationalQuotes[Random().nextInt(motivationalQuotes.length)],
        streak: currentStreak,
      ),
    );

    // Start confetti animation
    setState(() {
      showConfetti = true;
      _confettiList.clear();

      // Generate more confetti particles for fuller effect
      final random = Random();
      for (int i = 0; i < 100; i++) {
        _confettiList.add(
          Confetti(
            x: random.nextDouble(),
            y: -0.1 - (random.nextDouble() * 0.2),
            color: _getRandomColor(random),
            size: random.nextDouble() * 10 + 4,
            rotation: random.nextDouble() * 360,
            velocityY: random.nextDouble() * 1.5 + 0.8,
            velocityX: (random.nextDouble() - 0.5) * 0.6,
          ),
        );
      }
    });

    _confettiController?.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          showConfetti = false;
        });
        // Close overlay after 5 seconds
        Navigator.of(context).pop();
      }
    });
  }

  Color _getRandomColor(Random random) {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
      const Color(0xFFF38181),
      const Color(0xFFAA96DA),
      const Color(0xFFFCBF49),
      const Color(0xFF6C5CE7),
      const Color(0xFFFF7675),
      const Color(0xFF74B9FF),
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    // Get current date
    final now = DateTime.now();

    // Get last day of current month
    final lastDay = DateTime(now.year, now.month + 1, 0);

    // Calculate number of days in current month
    final daysInMonth = lastDay.day;

    // Generate all days for the current month
    final dates = List.generate(daysInMonth, (index) {
      return DateTime(now.year, now.month, index + 1);
    });

    return SizedBox(
      height: 76,
      child: Stack(
        children: [
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final dayNumber = date.day;
              final isSelected =
                  selectedDate.day == date.day &&
                  selectedDate.month == date.month &&
                  selectedDate.year == date.year;
              final hasLogin = _hasLogin(date);
              final isToday =
                  now.day == date.day &&
                  now.month == date.month &&
                  now.year == date.year;

              return GestureDetector(
                onTap: () {
                  if (mounted) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
                onLongPress: isToday ? _triggerCelebration : null,
                child: Container(
                  width: 48, // Optimized width for exact spacing
                  margin: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ), // Precise margins
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              const Color(0xFF3B82F6), // Medium blue
                              const Color(0xFF06B6D4), // Turquoise blue
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(
                      20,
                    ), // Perfect pill shape
                    border: isSelected
                        ? null
                        : Border.all(
                            color: hasLogin
                                ? const Color(
                                    0xFF10B981,
                                  ) // Green border for login days
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Number badge
                      Container(
                        width: 30, // Perfect size for the badge
                        height: 30,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : hasLogin
                              ? const Color(
                                  0xFFD1FAE5,
                                ) // Light green for login days
                              : const Color(0xFFE0F2FE), // Light blue
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 15, // Optimal font size
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? const Color(
                                      0xFF3B82F6,
                                    ) // Blue text on white
                                  : hasLogin
                                  ? const Color(
                                      0xFF10B981,
                                    ) // Green text for login
                                  : const Color(0xFF0EA5E9), // Light blue text
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5), // Perfect spacing
                      // Day text
                      Text(
                        'Day',
                        style: TextStyle(
                          fontSize: 12, // Optimal font size
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF0EA5E9), // Light blue
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Confetti overlay
          if (showConfetti && _confettiController != null)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: ConfettiPainter(
                    confettiList: _confettiList,
                    progress: _confettiController!.value,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Celebration Overlay Widget

class _CelebrationOverlay extends StatefulWidget {
  final String quote;
  final int streak;

  const _CelebrationOverlay({required this.quote, required this.streak});

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final List<Firework> _fireworks = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Generate fireworks
    final random = Random();
    for (int i = 0; i < 15; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          setState(() {
            _fireworks.add(
              Firework(
                x: random.nextDouble(),
                y: 0.3 + random.nextDouble() * 0.4,
                color: _getRandomColor(random),
              ),
            );
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRandomColor(Random random) {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
      const Color(0xFFFCBF49),
      const Color(0xFFAA96DA),
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Fireworks background
          ...(_fireworks.map(
            (firework) => _FireworkWidget(firework: firework),
          )),

          // Centered content
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF3B82F6), // Medium blue - same as calendar
                        Color(0xFF06B6D4), // Turquoise blue - same as calendar
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Streak count
                      Text(
                        '${widget.streak} Day Streak! 🔥',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Motivational quote
                      Text(
                        widget.quote,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Keep Going message
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Keep Going! 💪',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Firework widget
class _FireworkWidget extends StatefulWidget {
  final Firework firework;

  const _FireworkWidget({required this.firework});

  @override
  State<_FireworkWidget> createState() => _FireworkWidgetState();
}

class _FireworkWidgetState extends State<_FireworkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: FireworkPainter(
            x: widget.firework.x,
            y: widget.firework.y,
            color: widget.firework.color,
            progress: _animation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// Firework painter
class FireworkPainter extends CustomPainter {
  final double x;
  final double y;
  final Color color;
  final double progress;

  FireworkPainter({
    required this.x,
    required this.y,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(1.0 - progress)
      ..style = PaintingStyle.fill;

    final center = Offset(x * size.width, y * size.height);
    final radius = 60 * progress;

    // Draw multiple particles in a circle
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * (3.14159 / 180);
      final particleX = center.dx + radius * cos(angle);
      final particleY = center.dy + radius * sin(angle);

      canvas.drawCircle(
        Offset(particleX, particleY),
        4 * (1 - progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FireworkPainter oldDelegate) => true;
}

// Firework model
class Firework {
  final double x;
  final double y;
  final Color color;

  Firework({required this.x, required this.y, required this.color});
}

// Confetti particle model
class Confetti {
  double x;
  double y;
  final Color color;
  final double size;
  final double rotation;
  final double velocityY;
  final double velocityX;

  Confetti({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
    required this.velocityY,
    required this.velocityX,
  });
}

// Confetti painter
class ConfettiPainter extends CustomPainter {
  final List<Confetti> confettiList;
  final double progress;

  ConfettiPainter({required this.confettiList, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var confetti in confettiList) {
      // Update position based on progress
      final currentY =
          confetti.y + (confetti.velocityY * progress * size.height);
      final currentX =
          confetti.x * size.width +
          (confetti.velocityX * progress * size.width);

      // Only draw if still visible
      if (currentY < size.height) {
        final paint = Paint()
          ..color = confetti.color
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.translate(currentX, currentY);
        canvas.rotate(confetti.rotation * progress);

        // Draw confetti as small rectangles
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: confetti.size,
          height: confetti.size * 1.5,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(confetti.size / 4)),
          paint,
        );

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _GrowScreenState extends State<GrowScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Static reference to current instance for tour access
  static _GrowScreenState? _currentInstance;
  int _selectedBottomIndex = 0; // Bottom navigation index
  String _userName = 'Name';
  String? _userAvatarPath;
  final int _dayAtSea = 32;
  final String _destination = 'USA';
  final int _estimatedArrival = 4;
  double _wellnessScore = 30.0;
  List<SoarCardAnswer> _soarAnswers = [];
  List<dynamic> _userGoals = [];
  bool _loadingSoarData = true;
  bool _loadingGoals = true;

  // Guided Tour related
  late ScrollController _scrollController;
  bool _showSkipButton = false;

  // Avatar selection for chat image
  String _selectedAvatarName = 'Saira'; // Default to Saira

  // Avatar change subscription
  StreamSubscription<Map<String, String>>? _avatarChangeSubscription;

  @override
  void initState() {
    super.initState();
    _currentInstance = this; // Set current instance
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 1,
    ); // Default to Grow tab
    _scrollController = ScrollController();
    _loadUserData();
    _loadSoarData();
    _loadGoalsData();
    _loadAvatarSelection();
    _listenToAvatarChanges();
    _registerSkipButton();

    // Note: Avatar will be refreshed in didChangeDependencies when screen becomes visible
  }

  @override
  void dispose() {
    _currentInstance = null; // Clear current instance
    _avatarChangeSubscription?.cancel();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh avatar when screen becomes visible again
    print('🎭 [GROW_SCREEN] Screen dependencies changed, refreshing avatar...');
    _loadAvatarSelection();
  }

  void _startTutorial() {
    GuidedTourService.startTour(context);
  }

  void _registerSkipButton() {
    print('🎮 [GROW_SCREEN] Registering skip button...');
    GuidedTourService.registerSkipButton(
      showSkipButton: (onSkip) {
        print(
          '🎮 [GROW_SCREEN] showSkipButton called - setting _showSkipButton = true',
        );
        if (mounted) {
          setState(() {
            _showSkipButton = true;
          });
        }
        // Store the callback for later use
        _tourOnSkip = onSkip;
        print('🎮 [GROW_SCREEN] Skip button state updated');
      },
      hideSkipButton: () {
        print(
          '🎮 [GROW_SCREEN] hideSkipButton called - setting _showSkipButton = false',
        );
        if (mounted) {
          setState(() {
            _showSkipButton = false;
          });
        }
      },
    );
    print('🎮 [GROW_SCREEN] Skip button registration complete');
  }

  // Store skip button callback
  VoidCallback? _tourOnSkip;

  // Public method to access TabController for tour navigation
  TabController get tabController => _tabController;

  // Public method to access ScrollController for tour scrolling
  ScrollController get scrollController => _scrollController;

  // Load avatar selection for chat image
  Future<void> _loadAvatarSelection() async {
    try {
      print('🎭 [GROW_SCREEN] Loading avatar selection...');
      final selectedAvatar = await AvatarService.getSelectedAvatar();
      if (selectedAvatar != null) {
        print(
          '🎭 [GROW_SCREEN] Found selected avatar: ${selectedAvatar['name']}',
        );
        if (mounted) {
          setState(() {
            _selectedAvatarName = selectedAvatar['name']!;
          });
        }
        print(
          '🎭 [GROW_SCREEN] Set _selectedAvatarName to: $_selectedAvatarName',
        );
      } else {
        print(
          '🎭 [GROW_SCREEN] No selected avatar found, using default: Saira',
        );
      }
    } catch (e) {
      print('Error loading avatar selection: $e');
      // Keep default Saira if error occurs
    }
  }

  // Refresh avatar selection (called when returning from avatar change)
  Future<void> _refreshAvatarSelection() async {
    await _loadAvatarSelection();
  }

  // Listen to avatar changes from settings
  void _listenToAvatarChanges() {
    print('🎭 [GROW_SCREEN] Setting up avatar change listener');
    _avatarChangeSubscription = AvatarService.avatarChangeStream.listen((
      avatarData,
    ) {
      print('🎭 [GROW_SCREEN] Avatar changed to: ${avatarData['name']}');
      if (mounted) {
        setState(() {
          _selectedAvatarName = avatarData['name']!;
        });
        print(
          '🎭 [GROW_SCREEN] Updated _selectedAvatarName to: $_selectedAvatarName',
        );
      }
    });
  }

  // Get chat image path based on avatar selection
  String _getChatImagePath() {
    print(
      '🎭 [GROW_SCREEN] Getting chat image for avatar: $_selectedAvatarName',
    );
    switch (_selectedAvatarName.toLowerCase()) {
      case 'kael':
        print('🎭 [GROW_SCREEN] Using Kael chat image');
        return 'lib/assets/images/chat_kael.png';
      case 'saira':
      case 'siara':
      default:
        print('🎭 [GROW_SCREEN] Using Saira chat image');
        return 'lib/assets/images/chat.png';
    }
  }

  Future<void> _loadUserData() async {
    try {
      final profile = await UserProfileService.getUserProfile();
      final todaysMoodScore = await MoodService.getTodaysMoodScore();

      if (mounted) {
        setState(() {
          _userName = profile['name'] ?? 'Name';
          _userAvatarPath = profile['avatarPath'];
          _wellnessScore = todaysMoodScore;
        });
        // Also reload avatar selection for chat image
        _loadAvatarSelection();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadSoarData() async {
    try {
      final answers = await SoarCardService.loadSoarCardAnswers();
      if (mounted) {
        setState(() {
          _soarAnswers = answers;
          _loadingSoarData = false;
        });
      }
    } catch (e) {
      print('Error loading SOAR data: $e');
      if (mounted) {
        setState(() {
          _loadingSoarData = false;
        });
      }
    }
  }

  Future<void> _loadGoalsData() async {
    try {
      final result = await GoalService.getUserGoals();
      if (mounted) {
        setState(() {
          _userGoals = result['goals'] ?? [];
          _loadingGoals = false;
        });
      }
    } catch (e) {
      print('Error loading goals data: $e');
      if (mounted) {
        setState(() {
          _loadingGoals = false;
        });
      }
    }
  }

  void _onBottomNavTap(int index) {
    if (mounted) {
      setState(() {
        _selectedBottomIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          _selectedBottomIndex == 0
              ? _buildGrowScreenContent() // Show grow screen content
              : _getPageForIndex(_selectedBottomIndex), // Show other pages
          // Start Tour Button (bottom overlay)
          if (!_showSkipButton)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _startTutorial,
                backgroundColor: const Color(0xFF3498DB),
                child: const Icon(Icons.tour, color: Colors.white, size: 24),
              ),
            ),

          // Tour skip button overlay
          if (_showSkipButton)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: TourSkipButton(onSkip: _tourOnSkip ?? () {}),
            ),
        ],
      ),
      // bottomNavigationBar: CurvedNavigationBar(
      //   index: _selectedBottomIndex,
      //   height: 50,
      //   backgroundColor: const Color(0xFFF8F9FA),
      //   color: const Color(0xFF5DC1F3),
      //   buttonBackgroundColor: const Color(0xFF4A90E2),
      //   animationDuration: const Duration(milliseconds: 300),
      //   animationCurve: Curves.easeInOut,
      //   items: [
      //     // Home (Grow Screen)
      //     _selectedBottomIndex == 0
      //         ? const Icon(Icons.home, size: 32, color: Colors.white)
      //         : const Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Icon(Icons.home, size: 24, color: Colors.white),
      //               SizedBox(height: 2),
      //               Text(
      //                 'Home',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 12,
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //             ],
      //           ),
      //     // Journal
      //     _selectedBottomIndex == 1
      //         ? const Icon(Icons.book_rounded, size: 32, color: Colors.white)
      //         : const Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Icon(Icons.book_rounded, size: 24, color: Colors.white),
      //               SizedBox(height: 2),
      //               Text(
      //                 'Journal',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 12,
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //             ],
      //           ),
      //     // Chat
      //     _selectedBottomIndex == 2
      //         ? const Icon(
      //             Icons.chat_bubble_rounded,
      //             size: 32,
      //             color: Colors.white,
      //           )
      //         : const Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Icon(
      //                 Icons.chat_bubble_rounded,
      //                 size: 24,
      //                 color: Colors.white,
      //               ),
      //               SizedBox(height: 2),
      //               Text(
      //                 'Chat',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 12,
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //             ],
      //           ),
      //     // Settings
      //     _selectedBottomIndex == 3
      //         ? const Icon(Icons.settings, size: 32, color: Colors.white)
      //         : const Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Icon(Icons.settings, size: 24, color: Colors.white),
      //               SizedBox(height: 2),
      //               Text(
      //                 'Settings',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 12,
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //             ],
      //           ),
      //   ],
      //   onTap: _onBottomNavTap,
      // ),
    );
  }

  Widget _getPageForIndex(int index) {
    switch (index) {
      case 1:
        return const JournalScreen();
      case 2:
        return const ChatScreen();
      case 3:
        return const SettingsScreen();
      default:
        return _buildGrowScreenContent();
    }
  }

  Widget _buildGrowScreenContent() {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            backgroundColor: const Color(0xFFF8F9FA),
            elevation: 0,
            floating: false,
            pinned: false,
            snap: false,
            expandedHeight: 300.0, // Compact header
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  // Header - positioned at very top
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      MediaQuery.of(context).padding.top + 4,
                      20,
                      4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Profile Avatar
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserProfileScreen(),
                              ),
                            );
                            if (result == true) {
                              _loadUserData();
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _userAvatarPath != null
                                  ? (_userAvatarPath!.startsWith('lib/assets/'))
                                        ? Image.asset(
                                            _userAvatarPath!,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                  Icons.person,
                                                  color: Colors.grey,
                                                  size: 24,
                                                ),
                                          )
                                        : Image.file(
                                            File(_userAvatarPath!),
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                  Icons.person,
                                                  color: Colors.grey,
                                                  size: 24,
                                                ),
                                          )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                            ),
                          ),
                        ),

                        // Title - Centered
                        Image.asset(
                          "lib/assets/images/strive.png", // your PNG file
                          height: 40, // adjust as needed
                          fit: BoxFit.contain,
                        ),

                        // Menu Icon
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 235, 229, 229),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.menu,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 1),

                  Text(
                    AppLocalizations.of(context)!.seaSmart,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 53, 154, 255),
                    ),
                  ),

                  // User Info Card
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage("lib/assets/images/wave_bg.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.readyForTodaysJourney(_userName),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _StatCard(
                                value: '$_dayAtSea',
                                label: AppLocalizations.of(context)!.dayAtSea,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(width: 150),
                            Expanded(
                              child: _StatCard(
                                value: _destination,
                                label: AppLocalizations.of(
                                  context,
                                )!.destination,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 1),

                  // Horizontal Calendar
                  const HorizontalCalendar(),
                ],
              ),
            ),
          ),

          // Sticky Tab Bar
          SliverPersistentHeader(
            delegate: _StickyTabBarDelegate(
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: const BoxDecoration(),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.transparent,
                  unselectedLabelColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(
                      height: 46,
                      child: AvatarShowcaseWidget(
                        targetKey: GuidedTourService.knowTabKey,
                        title: "Know Tab 📚",
                        description:
                            "Access your knowledge hub with SOAR assessments, goal setting, and wellness tips.",
                        color: const Color(0xFF9B59B6),
                        child: AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, child) {
                            final isActive = _tabController.index == 0;
                            return Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFFE67E22)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.eco,
                                    size: 16,
                                    color: isActive
                                        ? Colors.white
                                        : const Color(0xFFE67E22),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'KNOW',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isActive
                                          ? Colors.white
                                          : const Color(0xFFE67E22),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Tab(
                      height: 46,
                      child: AvatarShowcaseWidget(
                        targetKey: GuidedTourService.growTabKey,
                        title: "Grow Tab 🌱",
                        description:
                            "Your activity center with games, breathing exercises, and wellness activities.",
                        color: const Color(0xFF2ECC71),
                        child: AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, child) {
                            final isActive = _tabController.index == 1;
                            return Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF3498DB)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    size: 16,
                                    color: isActive
                                        ? Colors.white
                                        : const Color(0xFF3498DB),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'GROW',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isActive
                                          ? Colors.white
                                          : const Color(0xFF3498DB),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Tab(
                      height: 46,
                      child: AvatarShowcaseWidget(
                        targetKey: GuidedTourService.showTabKey,
                        title: "Show Tab 📊",
                        description:
                            "Track your progress with analytics, achievements, and wellness journey insights.",
                        color: const Color(0xFFE67E22),
                        child: AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, child) {
                            final isActive = _tabController.index == 2;
                            return Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF2ECC71)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.menu_book,
                                    size: 16,
                                    color: isActive
                                        ? Colors.white
                                        : const Color(0xFF2ECC71),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'SHOW',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isActive
                                          ? Colors.white
                                          : const Color(0xFF2ECC71),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKnowContent(),
          _buildGrowContent(),
          _buildShowContent(),
        ],
      ),
    );
  }

  // Content methods for each tab
  Widget _buildKnowContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.knowledgeBase,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),

            // SOAR Card Tile
            _buildSoarCardTile(),
            const SizedBox(height: 16),

            // Goals Tile
            _buildGoalsTile(),
            const SizedBox(height: 16),

            Text(
              AppLocalizations.of(context)!.wellnessTips,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            _buildWellnessTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen width for responsive sizing
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Define responsive values based on screen width
        final isSmallScreen = screenWidth < 360;
        final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
        final isLargeScreen = screenWidth >= 600;

        // Responsive padding
        final horizontalPadding = isSmallScreen
            ? 16.0
            : (isMediumScreen ? 20.0 : 24.0);
        final verticalPadding = isSmallScreen ? 16.0 : 20.0;

        // Responsive spacing
        final sectionSpacing = isSmallScreen ? 16.0 : 24.0;
        final cardSpacing = isSmallScreen ? 8.0 : 12.0;

        // Responsive font sizes
        final titleFontSize = isSmallScreen ? 18.0 : 20.0;
        final chatCardHeight = screenHeight * 0.15; // 15% of screen height
        final consultCardHeight = screenHeight * 0.30; // 30% of screen height

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chat with Shipmate Section
                AvatarShowcaseWidget(
                  targetKey: GuidedTourService.chatWithBuddyKey,
                  title: "Chat with Your AI Buddy 🤖",
                  description:
                      "Get personalized support from your AI wellness companion anytime. Your buddy is here to help with mental health guidance and support.",
                  color: const Color(0xFF3498DB),
                  child: Container(
                    width: double.infinity,
                    height: chatCardHeight.clamp(100.0, 150.0),
                    alignment: Alignment.bottomRight,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(_getChatImagePath()),
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Wave pattern background
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: horizontalPadding,
                          top: horizontalPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [SizedBox(height: isSmallScreen ? 4 : 8)],
                          ),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChatScreen(),
                              ),
                            ),
                            child: Container(
                              height: chatCardHeight.clamp(80.0, 100.0),
                              width: screenWidth * 0.8,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(0, 255, 153, 0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: sectionSpacing),

                // Activity Section
                Text(
                  AppLocalizations.of(context)!.activity,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: cardSpacing + 4),

                AvatarShowcaseWidget(
                  targetKey: GuidedTourService.activitiesKey,
                  title: "Wellness Activities 🧘",
                  description:
                      "Engage in meditation and breathing exercises for stress relief and mental wellness. Perfect for life at sea.",
                  color: const Color(0xFF1ABC9C),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActivityCard(
                          title: AppLocalizations.of(context)!.meditation,
                          imagePath: 'lib/assets/images/med.png',
                          backgroundColor: Colors.white,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GridCalmGame(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: cardSpacing),
                      Expanded(
                        child: _ActivityCard(
                          title: AppLocalizations.of(context)!.breathing,
                          imagePath: 'lib/assets/images/bre.png',
                          backgroundColor: Colors.white,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BreathingScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: sectionSpacing),

                // Academy Section
                Text(
                  AppLocalizations.of(context)!.academy,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: cardSpacing + 4),

                // Consultation Card
                AvatarShowcaseWidget(
                  targetKey: GuidedTourService.academyKey,
                  title: "Academy Learning 🎓",
                  description:
                      "Access professional consultations and educational content. Learn from maritime wellness experts and professionals.",
                  color: const Color(0xFFE67E22),
                  child: Container(
                    width: double.infinity,
                    height: consultCardHeight.clamp(200.0, 300.0),
                    padding: EdgeInsets.all(horizontalPadding),
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('lib/assets/images/consult.png'),
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: cardSpacing + 4),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Academy(),
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 24,
                              vertical: isSmallScreen ? 12 : 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.consultWithUs,
                              style: TextStyle(
                                color: Color.fromARGB(0, 255, 255, 255),
                                fontWeight: FontWeight.bold,
                                fontSize: 50,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: sectionSpacing),

                // Games Section
                Text(
                  AppLocalizations.of(context)!.games,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: cardSpacing + 4),

                AvatarShowcaseWidget(
                  targetKey: GuidedTourService.gamesKey,
                  title: "Interactive Games 🎮",
                  description:
                      "Play calming games to improve focus and reduce stress. Perfect for mental wellness and relaxation.",
                  color: const Color(0xFF9B59B6),
                  child: Row(
                    children: [
                      Expanded(
                        child: _EnhancedGameCard(
                          title: AppLocalizations.of(context)!.tapToCalm,
                          subtitle: AppLocalizations.of(
                            context,
                          )!.tapForCalmness,
                          backgroundColor: const Color(0xFF3498DB),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GridCalmGame(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: cardSpacing + 4),
                      Expanded(
                        child: _EnhancedGameCard(
                          title: AppLocalizations.of(context)!.memory,
                          subtitle: '',
                          backgroundColor: const Color(0xFF90EE90),
                          isMemoryGame: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => MemoryGame()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: sectionSpacing),

                // Wellness Tips Section
                Text(
                  AppLocalizations.of(context)!.wellnessTips,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: cardSpacing + 4),

                AvatarShowcaseWidget(
                  targetKey: GuidedTourService.wellnessTipsGrowKey,
                  title: "Wellness Tips for Growth 💡",
                  description:
                      "Access growth-focused wellness tips designed to help you develop and improve your mental wellness skills.",
                  color: const Color(0xFF3498DB),
                  child: Column(
                    children: [
                      _WellnessTipCard(
                        title: 'Find Your Space',
                        description:
                            'Choose a quiet spot on deck or in your cabin where you won\'t be disturbed',
                        color: const Color(0xFF9B59B6),
                      ),
                      SizedBox(height: cardSpacing),
                      _WellnessTipCard(
                        title: 'Deep Breathing',
                        description:
                            'Practice breathing exercises to reduce stress and improve focus',
                        color: const Color(0xFF3498DB),
                      ),
                      SizedBox(height: cardSpacing),
                      _WellnessTipCard(
                        title: 'Stay Active',
                        description:
                            'Regular movement helps maintain both physical and mental wellness',
                        color: const Color(0xFF2ECC71),
                      ),
                      SizedBox(height: cardSpacing),
                      _WellnessTipCard(
                        title: 'Connect with Others',
                        description:
                            'Maintain social connections for emotional support and wellbeing',
                        color: const Color(0xFFE67E22),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: sectionSpacing + 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShowContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Title
            Text(
              AppLocalizations.of(context)!.yourProgress,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Progress Feature Cards (Grid Style)
            AvatarShowcaseWidget(
              targetKey: GuidedTourService.progressCardsKey,
              title: "Progress Tracking 📈",
              description:
                  "View your wellness progress through journal entries, mood tracking, and analytics. See how you're growing over time.",
              color: const Color(0xFF2ECC71),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 1,
                childAspectRatio: 2.0,
                mainAxisSpacing: 12,

                children: [
                  _buildFeatureCard(
                    AppLocalizations.of(context)!.journal,
                    "lib/assets/images/resolu.png",
                    '/journal',
                  ),
                  _buildFeatureCard(
                    AppLocalizations.of(context)!.certificates,
                    "lib/assets/images/certi.png",
                    '/certificates',
                  ),
                  _buildFeatureCard(
                    AppLocalizations.of(context)!.moodAnalysis,
                    "lib/assets/images/prog.png",
                    '/mood-analytics',
                  ),
                  _buildFeatureCard(
                    AppLocalizations.of(context)!.progressReport,
                    "lib/assets/images/aly.png",
                    '/report',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 Wellness Tips Section
            Text(
              AppLocalizations.of(context)!.wellnessTips,
              textAlign: TextAlign.center, // ✅ move here
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),

            const SizedBox(height: 12),

            AvatarShowcaseWidget(
              targetKey: GuidedTourService.wellnessTipsShowKey,
              title: "Wellness Tips for Progress 💡",
              description:
                  "Access progress-focused wellness tips to help you maintain and improve your wellness journey over time.",
              color: const Color(0xFF3498DB),
              child: Column(
                children: [
                  _buildTipCard(
                    title: "Find Your Space",
                    description:
                        "Choose a quiet spot on deck or in your cabin where you won’t disturbed",
                    bgColor: Colors.green.shade50,
                    textColor: Colors.green.shade800,
                  ),
                  _buildTipCard(
                    title: "Steady Yourself",
                    description:
                        "Sit with your back against something stable to maintain balance with ship movement",
                    bgColor: Colors.purple.shade50,
                    textColor: Colors.purple,
                  ),
                  _buildTipCard(
                    title: "Use Natural Sounds",
                    description:
                        "Let the sound of waves and wind become part of your meditation practice",
                    bgColor: Colors.blue.shade50,
                    textColor: Colors.blue,
                  ),
                  _buildTipCard(
                    title: "Regular Practice",
                    description:
                        "Even 5 minutes daily can significantly reduce stress and improve focus.",
                    bgColor: Colors.orange.shade50,
                    textColor: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Feature Card
  Widget _buildFeatureCard(String title, String imagePath, String routeName) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(106, 8, 122, 183),
                      const Color.fromARGB(0, 1, 1, 29),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Wellness Tip Card
  Widget _buildTipCard({
    required String title,
    required String description,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSoarCardTile() {
    return AvatarShowcaseWidget(
      targetKey: GuidedTourService.soarAssessmentKey,
      title: "SOAR Assessment 🎯",
      description:
          "Complete your wellness assessment to understand your strengths and growth areas. This helps personalize your wellness journey.",
      color: const Color(0xFF9B59B6),
      child: GestureDetector(
        onTap: () async {
          // Navigate to SOAR card screen
          final userEmail = await UserProfileService.getUserEmail();
          if (userEmail.isNotEmpty && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SoarDashboardPage(userEmail: userEmail),
              ),
            ).then((_) {
              // Refresh SOAR data when returning
              _loadSoarData();
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B59B6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.quiz,
                      color: Color(0xFF9B59B6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.soarAssessment,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        Text(
                          _loadingSoarData
                              ? AppLocalizations.of(
                                  context,
                                )!.loadingCertificates
                              : _soarAnswers.isEmpty
                              ? AppLocalizations.of(
                                  context,
                                )!.completeYourAssessment
                              : '${_soarAnswers.length} ${AppLocalizations.of(context)!.questionsAnswered}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),

              if (!_loadingSoarData && _soarAnswers.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.recentAnswers,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                ...(_soarAnswers
                    .take(3)
                    .map(
                      (answer) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(top: 8, right: 8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF9B59B6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    answer.questionText,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2C3E50),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${AppLocalizations.of(context)!.answerLabel} ${answer.answer}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9B59B6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                if (_soarAnswers.length > 3)
                  Text(
                    'and ${_soarAnswers.length - 3} more...',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],

              if (!_loadingSoarData && _soarAnswers.isEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B59B6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.takeSoarAssessment,
                    style: TextStyle(fontSize: 12, color: Color(0xFF9B59B6)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsTile() {
    return AvatarShowcaseWidget(
      targetKey: GuidedTourService.goalsKey,
      title: "Goal Setting 🎯",
      description:
          "Set and track your wellness goals for fitness, study, and personal growth. Define what you want to achieve.",
      color: const Color(0xFF2ECC71),
      child: GestureDetector(
        onTap: () async {
          // Navigate to goal setting screen
          final userEmail = await UserProfileService.getUserEmail();
          if (userEmail.isNotEmpty && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GoalSet(userEmail: userEmail),
              ),
            ).then((_) {
              // Refresh goals data when returning
              _loadGoalsData();
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.flag,
                      color: Color(0xFF2ECC71),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.goalSetting,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        Text(
                          _loadingGoals
                              ? AppLocalizations.of(
                                  context,
                                )!.loadingCertificates
                              : _userGoals.isEmpty
                              ? AppLocalizations.of(
                                  context,
                                )!.setYourWellnessGoals
                              : '${_userGoals.length} ${AppLocalizations.of(context)!.goalsSet}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),

              if (!_loadingGoals && _userGoals.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.yourGoals,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                ...(_userGoals
                    .take(3)
                    .map(
                      (goal) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(top: 8, right: 8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2ECC71),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal['goals'] ?? goal['goal'] ?? 'Goal',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2C3E50),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (goal['notes'] != null &&
                                      goal['notes'].toString().isNotEmpty)
                                    Text(
                                      goal['notes'],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                if (_userGoals.length > 3)
                  Text(
                    'and ${_userGoals.length - 3} more goals...',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],

              if (!_loadingGoals && _userGoals.isEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.setWellnessGoalsDescription,
                    style: TextStyle(fontSize: 12, color: Color(0xFF2ECC71)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatWithAIButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3498DB).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chat with Buddy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get personalized wellness guidance and support',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodAnalyticsButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MoodAnalyticsScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 109, 159, 223),
              Color.fromARGB(255, 97, 183, 226),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(
                255,
                109,
                159,
                223,
              ).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mood Analytics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track and analyze your mood patterns over time',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _GameCard(
          title: 'Meditation',
          icon: Icons.touch_app,
          color: const Color(0xFF9B59B6),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GridCalmGame()),
          ),
        ),
        _GameCard(
          title: 'Breathing',
          icon: Icons.air,
          color: const Color(0xFF1ABC9C),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BreathingScreen()),
          ),
        ),
        _GameCard(
          title: 'Memory Game',
          icon: Icons.psychology,
          color: const Color(0xFFE67E22),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MemoryGame()),
          ),
        ),
        _GameCard(
          title: 'Journal',
          icon: Icons.book,
          color: const Color(0xFF34495E),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JournalScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildWellnessTips() {
    return AvatarShowcaseWidget(
      targetKey: GuidedTourService.wellnessTipsKnowKey,
      title: "Wellness Tips 💡",
      description:
          "Access expert wellness tips and breathing techniques designed specifically for life at sea. Learn from maritime wellness research.",
      color: const Color(0xFF3498DB),
      child: Column(
        children: _getWellnessTipsList()
            .map(
              (tip) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (tip['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        tip['icon'] as IconData,
                        color: tip['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['title'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tip['description'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _getWellnessTipsList() {
    return [
      {
        'title': 'Daily Breathing Exercise',
        'description':
            'Practice deep breathing for 5 minutes daily to reduce stress and anxiety.',
        'icon': Icons.air,
        'color': const Color(0xFF1ABC9C),
      },
      {
        'title': 'Stay Connected',
        'description':
            'Maintain regular contact with family and friends to combat loneliness.',
        'icon': Icons.people,
        'color': const Color(0xFF3498DB),
      },
      {
        'title': 'Physical Activity',
        'description':
            'Engage in regular exercise to boost mood and maintain physical health.',
        'icon': Icons.fitness_center,
        'color': const Color(0xFFE74C3C),
      },
      {
        'title': 'Mindful Eating',
        'description':
            'Pay attention to your meals and maintain a balanced diet for better wellness.',
        'icon': Icons.restaurant,
        'color': const Color(0xFFE67E22),
      },
      {
        'title': 'Quality Sleep',
        'description':
            'Maintain a regular sleep schedule for better mental and physical health.',
        'icon': Icons.bedtime,
        'color': const Color(0xFF9B59B6),
      },
      {
        'title': 'Express Yourself',
        'description':
            'Write in a journal or talk to someone about your feelings and experiences.',
        'icon': Icons.edit,
        'color': const Color(0xFF2ECC71),
      },
    ];
  }

  Widget _buildMeditationTipsCard() {
    final tips = [
      {
        'title': 'Find a Quiet Space',
        'description':
            'Choose a quiet spot on deck or in your cabin where you wont be disturbed.',
        'icon': Icons.self_improvement,
        'color': const Color(0xFF1ABC9C),
      },
      {
        'title': 'Use Natural Sounds',
        'description':
            'Let the sound of the ocean waves and wind enhance your meditation experience.',
        'icon': Icons.waves,
        'color': const Color.fromARGB(255, 64, 97, 231),
      },
      {
        'title': 'Steady Yourself',
        'description':
            'Sit with your back against something stable to maintain balance with ship movement',
        'icon': Icons.anchor,
        'color': const Color.fromARGB(255, 141, 63, 224),
      },
      {
        'title': 'Regular Practice',
        'description':
            'Even 5 minutes daily can significantly reduce stress and improve focus.',
        'icon': Icons.schedule,
        'color': const Color.fromARGB(255, 218, 114, 58),
      },
    ];

    return Column(
      children: tips
          .map(
            (tip) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(213, 255, 255, 255),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (tip['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      tip['icon'] as IconData,
                      color: tip['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip['description'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildProgressCards() {
    return Column(
      children: [
        _ProgressCard(
          title: 'Daily Check-ins',
          value: '7/7',
          progress: 1.0,
          color: const Color(0xFF2ECC71),
        ),
        const SizedBox(height: 12),
        _ProgressCard(
          title: 'Breathing Sessions',
          value: '12/15',
          progress: 0.8,
          color: const Color(0xFF3498DB),
        ),
        const SizedBox(height: 12),
        _ProgressCard(
          title: 'Journal Entries',
          value: '5/7',
          progress: 0.7,
          color: const Color(0xFFE67E22),
        ),
      ],
    );
  }
}

// Activity Card Widget
class _ActivityCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.title,
    required this.imagePath,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Image.asset(imagePath, fit: BoxFit.contain)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Game Card Widget
class _EnhancedGameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final bool isMemoryGame;
  final VoidCallback onTap;

  const _EnhancedGameCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    this.isMemoryGame = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: isMemoryGame
            ? _buildMemoryGameContent()
            : _buildTapToCalmContent(),
      ),
    );
  }

  Widget _buildTapToCalmContent() {
    return Container(
      height: 150, // adjust height as needed
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage(
            'lib/assets/images/game1.png',
          ), // your background PNG
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 255, 255, 255),
                  borderRadius: BorderRadius.circular(8),
                ),
                // child: Image.asset(
                //   'lib/assets/images/game1.png',
                //   height: 24,
                //   width: 24,
                //   fit: BoxFit.contain,
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryGameContent() {
    return Container(
      height: 150, // adjust height as needed
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage(
            'lib/assets/images/game2.png',
          ), // single PNG background
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'MEMORY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Wellness Tip Card Widget
class _WellnessTipCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;

  const _WellnessTipCard({
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sticky Tab Bar Delegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate(this.child);

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFFF8F9FA), child: child);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD).withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFBBDEFB).withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF424242),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final Color color;

  const _ProgressCard({
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
