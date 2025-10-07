import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleGuidedTourService {
  static const String _tourCompletedKey = 'simple_guided_tour_completed';
  static bool _isTourActive = false;

  /// Check if the user has completed the guided tour
  static Future<bool> hasCompletedTour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tourCompletedKey) ?? false;
  }

  /// Mark the guided tour as completed
  static Future<void> markTourCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tourCompletedKey, true);
  }

  /// Reset the guided tour
  static Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tourCompletedKey);
  }

  /// Start a simple guided tour using dialogs
  static void startSimpleTour(BuildContext context) {
    _isTourActive = true;
    _showTourDialog(context, 0);
  }

  /// Show tour dialog with step information
  static void _showTourDialog(BuildContext context, int step) {
    final tourSteps = [
      {
        'title': 'Welcome to Sea Smart! 🌊',
        'description': 'Let\'s explore the three main sections: Know, Grow, and Show. Each section helps you on your wellness journey at sea.',
        'icon': Icons.explore,
        'color': Color(0xFF3498DB),
      },
      {
        'title': 'Know Tab 📚',
        'description': 'Click here to access your knowledge hub! Find SOAR assessments, set goals, and wellness tips.',
        'icon': Icons.school,
        'color': Color(0xFF9B59B6),
      },
      {
        'title': 'Grow Tab 🌱',
        'description': 'Your activity center! Engage with games, breathing exercises, and activities to develop your wellness skills.',
        'icon': Icons.psychology,
        'color': Color(0xFF2ECC71),
      },
      {
        'title': 'Show Tab 📊',
        'description': 'Click here to track your progress! View analytics, achievements, and see your wellness journey.',
        'icon': Icons.analytics,
        'color': Color(0xFFE67E22),
      },
      {
        'title': 'SOAR Assessment 🎯',
        'description': 'Complete your wellness assessment to understand your strengths and growth areas.',
        'icon': Icons.quiz,
        'color': Color(0xFF9B59B6),
      },
      {
        'title': 'Goal Setting 🎯',
        'description': 'Set and track your wellness goals for fitness, study, and personal growth.',
        'icon': Icons.flag,
        'color': Color(0xFF2ECC71),
      },
      {
        'title': 'Chat with Your Buddy 🤖',
        'description': 'Get personalized support from your AI wellness buddy anytime.',
        'icon': Icons.chat,
        'color': Color(0xFF3498DB),
      },
      {
        'title': 'Wellness Activities 🧘',
        'description': 'Engage in meditation and breathing exercises for stress relief.',
        'icon': Icons.self_improvement,
        'color': Color(0xFF1ABC9C),
      },
      {
        'title': 'Academy Learning 🎓',
        'description': 'Access professional consultations and educational content.',
        'icon': Icons.school,
        'color': Color(0xFFE67E22),
      },
      {
        'title': 'Interactive Games 🎮',
        'description': 'Play calming games to improve focus and reduce stress.',
        'icon': Icons.games,
        'color': Color(0xFF9B59B6),
      },
      {
        'title': 'Progress Tracking 📈',
        'description': 'View your wellness progress through journal entries and mood tracking.',
        'icon': Icons.trending_up,
        'color': Color(0xFF2ECC71),
      },
      {
        'title': 'Tour Complete! 🎉',
        'description': 'Great job! You\'ve completed the guided tour. You now know how to navigate Sea Smart and use all its features.',
        'icon': Icons.celebration,
        'color': Color(0xFF2ECC71),
      },
    ];

    if (step >= tourSteps.length) {
      _isTourActive = false;
      markTourCompleted();
      return;
    }

    final currentStep = tourSteps[step];
    final isLastStep = step == tourSteps.length - 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: currentStep['color'] as Color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                currentStep['icon'] as IconData,
                color: Colors.white,
                size: 40,
              ),
            ),
            SizedBox(height: 20),
            Text(
              currentStep['title'] as String,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              currentStep['description'] as String,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                // Progress indicator
                Expanded(
                  child: LinearProgressIndicator(
                    value: (step + 1) / tourSteps.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      currentStep['color'] as Color,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '${step + 1}/${tourSteps.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (!isLastStep) ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _isTourActive = false;
              },
              child: Text(
                'Skip Tour',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showTourDialog(context, step + 1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStep['color'] as Color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Next'),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _isTourActive = false;
                markTourCompleted();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStep['color'] as Color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Got it!'),
            ),
          ],
        ],
      ),
    );
  }

  /// Check if tour is currently active
  static bool get isTourActive => _isTourActive;

  /// Set tour active state
  static void setTourActive(bool active) {
    _isTourActive = active;
  }
}
