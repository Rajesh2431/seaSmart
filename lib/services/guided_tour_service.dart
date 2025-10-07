import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/grow_screen.dart';

class GuidedTourService {
  static const String _tourCompletedKey = 'guided_tour_completed';
  static const String _tourStepKey = 'guided_tour_step';
  static bool _isTourActive = false;
  
  // Tour state management
  static final bool _showSkipButton = false;
  static Function(VoidCallback onSkip)? _showSkipButtonCallback;
  static Function()? _hideSkipButtonCallback;

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

  /// Reset the guided tour (for testing or if user wants to retake)
  static Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tourCompletedKey);
    await prefs.remove(_tourStepKey);
  }

  /// Get the current tour step
  static Future<int> getCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tourStepKey) ?? 0;
  }

  /// Set the current tour step
  static Future<void> setCurrentStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tourStepKey, step);
  }

  /// Start the guided tour using showcaseview package
  static void startTour(BuildContext context) {
    _isTourActive = true;
    print('🚀 [TOUR] Starting tour with context: ${context.mounted}');
    
    // Try to start with a simple test first
    _testShowcaseContext(context);
  }

  /// Test if ShowCaseWidget context is available
  static void _testShowcaseContext(BuildContext context) {
    print('🧪 [TEST] Testing ShowCaseWidget context...');
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!context.mounted) {
        print('❌ [TEST] Context not mounted');
        return;
      }
      
      try {
        ShowCaseWidget.of(context);
        print('✅ [TEST] ShowCaseWidget context available, starting comprehensive tour');
        _startComprehensiveTour(context);
      } catch (e) {
        print('❌ [TEST] ShowCaseWidget context not available: $e');
        print('🔄 [TEST] Retrying in 1 second...');
        
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            try {
              ShowCaseWidget.of(context);
              print('✅ [TEST] ShowCaseWidget context available on retry, starting tour');
              _startComprehensiveTour(context);
            } catch (e) {
              print('❌ [TEST] ShowCaseWidget still not available: $e');
              _showTourFallbackDialog(context);
            }
          }
        });
      }
    });
  }

  /// Check if tour is currently active
  static bool get isTourActive => _isTourActive;

  /// Set tour active state
  static void setTourActive(bool active) {
    _isTourActive = active;
  }

  /// Register skip button functions
  static void registerSkipButton({
    required Function(VoidCallback onSkip) showSkipButton,
    required Function() hideSkipButton,
  }) {
    print('🎮 [REGISTER] Registering skip button...');
    _showSkipButtonCallback = showSkipButton;
    _hideSkipButtonCallback = hideSkipButton;
    print('🎮 [REGISTER] Skip button registered successfully');
  }




  /// Start automatic tour with skip button
  static Future<void> _startAutomaticTour(BuildContext context) async {
    print('🚀 [AUTOMATIC_TOUR] Starting automatic tour...');
    
    _isTourActive = true;
    
    // Show skip button
    _showSkipButtonCallback?.call(() => _skipTour(context));
    
    try {
      // STEP 1: Navigate to Know Tab and explain it
      print('📚 [STEP_1] Navigate to Know Tab and explain...');
      await _navigateToTab(context, 'Know Tab');
      await _scrollToTop(context);
      await Future.delayed(const Duration(milliseconds: 1000));
      await _highlightElement(context, _knowTabKey, 'Know Tab', 2000);
      
      // STEP 2: SOAR Assessment
      print('📋 [STEP_2] Highlight SOAR Assessment...');
      await _highlightElement(context, _soarAssessmentKey, 'SOAR Assessment', 2000);
      
      // STEP 3: Goal Setting
      print('🎯 [STEP_3] Highlight Goal Setting...');
      await _highlightElement(context, _goalsKey, 'Goal Setting', 2000);
      
      // STEP 4: Navigate to Grow Tab and explain it
      print('🌱 [STEP_4] Navigate to Grow Tab and explain...');
      await _navigateToTab(context, 'Grow Tab');
      await _scrollToTop(context);
      await Future.delayed(const Duration(milliseconds: 1000));
      await _highlightElement(context, _growTabKey, 'Grow Tab', 2000);
      
      // STEP 5: Chat with AI Buddy
      print('💬 [STEP_5] Highlight Chat with AI Buddy...');
      await _highlightElement(context, _chatWithBuddyKey, 'Chat with Your AI Buddy', 2000);
      
      // STEP 6: Wellness Activities
      print('🧘 [STEP_6] Highlight Wellness Activities...');
      await _scrollDown(context);
      await Future.delayed(const Duration(milliseconds: 500));
      await _highlightElement(context, _activitiesKey, 'Wellness Activities', 2000);
      
      // STEP 7: Academy
      print('🎓 [STEP_7] Highlight Academy...');
      await _scrollDown(context);
      await Future.delayed(const Duration(milliseconds: 500));
      await _highlightElement(context, _academyKey, 'Academy', 2000);
      
      // STEP 8: Interactive Games
      print('🎮 [STEP_8] Highlight Interactive Games...');
      await _scrollDown(context);
      await Future.delayed(const Duration(milliseconds: 500));
      await _highlightElement(context, _gamesKey, 'Interactive Games', 2000);
      
      // STEP 9: Navigate to Show Tab and explain it
      print('📊 [STEP_9] Navigate to Show Tab and explain...');
      await _navigateToTab(context, 'Show Tab');
      await _scrollToTop(context);
      await Future.delayed(const Duration(milliseconds: 1000));
      await _highlightElement(context, _showTabKey, 'Show Tab', 2000);
      
      // STEP 10: Progress Tracker
      print('📈 [STEP_10] Highlight Progress Tracker...');
      await _highlightElement(context, _progressCardsKey, 'Progress Tracker', 2000);
      
      // STEP 11: Scroll down and highlight Wellness Tips
      print('💡 [STEP_11] Scroll down and highlight Wellness Tips...');
      await _scrollDown(context);
      await Future.delayed(const Duration(milliseconds: 500));
      await _highlightElement(context, _wellnessTipsShowKey, 'Wellness Tips', 2000);
      
      // STEP 12: Scroll all the way up and end tour
      print('🏁 [STEP_12] Scroll to top and end tour...');
      await _scrollToTop(context);
      await Future.delayed(const Duration(milliseconds: 1000));
      
      print('✅ [AUTOMATIC_TOUR] Tour completed successfully!');
    } catch (e) {
      print('❌ [AUTOMATIC_TOUR] Error during tour: $e');
    } finally {
      await _endTour(context);
    }
  }

  /// Skip entire tour
  static Future<void> _skipTour(BuildContext context) async {
    print('⏭️ [AUTOMATIC_TOUR] Tour skipped by user');
    await _endTour(context);
  }

  /// End tour
  static Future<void> _endTour(BuildContext context) async {
    print('🏁 [AUTOMATIC_TOUR] Tour ended');
    _hideSkipButtonCallback?.call();
    _isTourActive = false;
    
    // Dismiss any active showcase
    try {
      ShowCaseWidget.of(context).dismiss();
    } catch (e) {
      print('Note: No active showcase to dismiss');
    }
    
    // Mark tour as completed
    await markTourCompleted();
  }

  /// Navigate to Know Tab and show the Know screen content
  static Future<void> _navigateToKnowTabAndShow(BuildContext context) async {
    try {
      print('🔄 [TOUR_START] Navigating to Know Tab...');
      
      // Navigate to Know Tab
      final tabController = GrowScreen.currentTabController;
      if (tabController != null) {
        tabController.animateTo(0); // Know Tab is index 0
        print('✅ [TOUR_START] Navigated to Know Tab');
        
        // Wait for tab animation to complete
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Scroll to top to show the Know screen content clearly
        await _scrollToTop(context);
        
        // Wait a moment for user to see the Know screen
        await Future.delayed(const Duration(milliseconds: 1000));
        
        print('✅ [TOUR_START] Know Tab screen is now visible and ready for tour');
      } else {
        print('⚠️ [TOUR_START] No TabController found');
      }
    } catch (e) {
      print('❌ [TOUR_START] Error navigating to Know Tab: $e');
    }
  }

  /// Scroll to top of the current tab
  static Future<void> _scrollToTop(BuildContext context) async {
    try {
      // Get the ScrollController from GrowScreen
      final scrollController = GrowScreen.currentScrollController;
      if (scrollController != null) {
        await scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
        print('✅ [SCROLL_TOP] Scrolled to top');
      }
    } catch (e) {
      print('❌ [SCROLL_TOP] Error scrolling to top: $e');
    }
  }

  /// Scroll down in the current tab
  static Future<void> _scrollDown(BuildContext context) async {
    try {
      final scrollController = GrowScreen.currentScrollController;
      if (scrollController != null) {
        final currentPosition = scrollController.position.pixels;
        final maxScroll = scrollController.position.maxScrollExtent;
        final targetPosition = (currentPosition + 300).clamp(0.0, maxScroll);
        
        await scrollController.animateTo(
          targetPosition,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
        print('✅ [SCROLL_DOWN] Scrolled down');
      }
    } catch (e) {
      print('❌ [SCROLL_DOWN] Error scrolling down: $e');
    }
  }

  /// Navigate to element and highlight it
  static Future<void> _navigateAndHighlight(BuildContext context, GlobalKey targetKey, String title, int highlightDuration) async {
    try {
      if (targetKey.currentContext == null) {
        print('⚠️ [NAVIGATE] $title not found, skipping...');
        return;
      }

      print('🎯 [NAVIGATE] Navigating to: $title');
      
      // Handle tab navigation
      if (title.contains('Tab')) {
        await _navigateToTab(context, title);
      }
      
      // Scroll to element first
      await _scrollToElement(context, targetKey, title);
      
      // Wait a bit for scroll to settle
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Highlight the specific element using showcase
      await _highlightElement(context, targetKey, title, highlightDuration);
      
      print('✅ [NAVIGATE] Completed: $title');
    } catch (e) {
      print('❌ [NAVIGATE] Error with $title: $e');
    }
  }

  /// Navigate to specific tab
  static Future<void> _navigateToTab(BuildContext context, String tabName) async {
    try {
      print('🔄 [TAB_NAV] Navigating to $tabName...');
      
      // Get the TabController from GrowScreen
      final tabController = GrowScreen.currentTabController;
      if (tabController != null) {
        int tabIndex = 0;
        if (tabName.contains('Know Tab')) {
          tabIndex = 0;
        } else if (tabName.contains('Grow Tab')) {
          tabIndex = 1;
        } else if (tabName.contains('Show Tab')) {
          tabIndex = 2;
        }
        
        // Navigate to the tab
        tabController.animateTo(tabIndex);
        print('✅ [TAB_NAV] Navigated to $tabName (index: $tabIndex)');
        
        // Wait for tab animation to complete
        await Future.delayed(const Duration(milliseconds: 800));
      } else {
        print('⚠️ [TAB_NAV] No GrowScreen state found');
      }
    } catch (e) {
      print('❌ [TAB_NAV] Error navigating to tab: $e');
    }
  }

  /// Highlight specific element using showcase
  static Future<void> _highlightElement(BuildContext context, GlobalKey targetKey, String title, int highlightDuration) async {
    try {
      print('✨ [HIGHLIGHT] Highlighting: $title');
      
      // Get the ShowCaseWidget and highlight the specific element
      final showCaseWidget = ShowCaseWidget.of(context);
      
      // Create a list with just this element for highlighting
      final List<GlobalKey> singleElementKeys = [targetKey];
      
      // Start showcase for this single element
      showCaseWidget.startShowCase(singleElementKeys);
      
      // Wait for the highlight duration
      await Future.delayed(Duration(milliseconds: highlightDuration));
      
      // Dismiss the current showcase
      showCaseWidget.dismiss();
      
      print('✅ [HIGHLIGHT] Completed highlighting: $title');
    } catch (e) {
      print('❌ [HIGHLIGHT] Error highlighting $title: $e');
    }
  }

  /// Scroll to specific element
  static Future<void> _scrollToElement(BuildContext context, GlobalKey targetKey, String title) async {
    try {
      final RenderBox? renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        // Get the ScrollController from GrowScreen
        final ScrollController? scrollController = GrowScreen.currentScrollController;
        if (scrollController != null) {
          final Offset globalPosition = renderBox.localToGlobal(Offset.zero);
          final double elementTop = globalPosition.dy;
          final double viewportHeight = MediaQuery.of(context).size.height;
          final double appBarHeight = 100;
          
          print('🎯 [TOUR_SCROLL] Scrolling to: $title at position $elementTop');
          
          double targetScroll;
          if (title.contains('Tab')) {
            // Tab elements - scroll to top to show the tab clearly
            targetScroll = 0;
            print('🎯 [TOUR_SCROLL] Tab element - scrolling to top');
          } else if (title.contains('Chat with Your AI Buddy')) {
            // AI Buddy - no scroll (already visible)
            targetScroll = scrollController.position.pixels;
            print('🎯 [TOUR_SCROLL] AI Buddy - keeping current position');
          } else {
            // Other elements - scroll to center
            targetScroll = scrollController.position.pixels + (elementTop - (viewportHeight / 2) - appBarHeight);
            print('🎯 [TOUR_SCROLL] Scrolling to center element');
          }
          
          final double maxScroll = scrollController.position.maxScrollExtent;
          final double finalPosition = targetScroll.clamp(0.0, maxScroll);
          
          await scrollController.animateTo(
            finalPosition,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
          
          print('🎯 [TOUR_SCROLL] Scrolled to $title at position $finalPosition');
        } else {
          print('❌ [TOUR_SCROLL] No GrowScreen state found for $title - skipping scroll');
        }
      } else {
        print('❌ [TOUR_SCROLL] No RenderBox found for $title - skipping scroll');
      }
    } catch (e) {
      print('❌ [TOUR_SCROLL] Error scrolling to $title: $e');
    }
  }


  /// Start the showcase tour directly (for testing)
  static void startShowcaseTour(BuildContext context) {
    print('🧪 [TEST] Direct showcase tour triggered!');
    _startShowcaseViewTour(context);
  }

  /// Start comprehensive tour covering all three tabs
  static void _startComprehensiveTour(BuildContext context) {
    print('🚀 [COMPREHENSIVE] Starting comprehensive tour...');
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!context.mounted) {
        print('❌ [COMPREHENSIVE] Context not mounted');
        return;
      }
      
      try {
        // Check if ShowCaseWidget is available
        ShowCaseWidget.of(context);
        print('✅ [COMPREHENSIVE] ShowCaseWidget context found');
        
        // Define the comprehensive order of elements
        final orderedKeys = <GlobalKey>[];
        
        // Add elements in the comprehensive order
        if (_knowTabKey.currentContext != null) {
          orderedKeys.add(_knowTabKey);
          print('✅ [COMPREHENSIVE] Know tab available (1/13)');
        }
        
        if (_soarAssessmentKey.currentContext != null) {
          orderedKeys.add(_soarAssessmentKey);
          print('✅ [COMPREHENSIVE] SOAR Assessment available (2/13)');
        }
        
        if (_goalsKey.currentContext != null) {
          orderedKeys.add(_goalsKey);
          print('✅ [COMPREHENSIVE] Goals available (3/13)');
        }
        
        if (_wellnessTipsKnowKey.currentContext != null) {
          orderedKeys.add(_wellnessTipsKnowKey);
          print('✅ [COMPREHENSIVE] Wellness Tips (Know) available (4/13)');
        }
        
        if (_growTabKey.currentContext != null) {
          orderedKeys.add(_growTabKey);
          print('✅ [COMPREHENSIVE] Grow tab available (5/13)');
        }
        
        if (_chatWithBuddyKey.currentContext != null) {
          orderedKeys.add(_chatWithBuddyKey);
          print('✅ [COMPREHENSIVE] Chat with Buddy available (6/13)');
        }
        
        if (_activitiesKey.currentContext != null) {
          orderedKeys.add(_activitiesKey);
          print('✅ [COMPREHENSIVE] Activities available (7/13)');
        }
        
        if (_academyKey.currentContext != null) {
          orderedKeys.add(_academyKey);
          print('✅ [COMPREHENSIVE] Academy available (8/13)');
        }
        
        if (_gamesKey.currentContext != null) {
          orderedKeys.add(_gamesKey);
          print('✅ [COMPREHENSIVE] Games available (9/13)');
        }
        
        if (_wellnessTipsGrowKey.currentContext != null) {
          orderedKeys.add(_wellnessTipsGrowKey);
          print('✅ [COMPREHENSIVE] Wellness Tips (Grow) available (10/13)');
        }
        
        if (_showTabKey.currentContext != null) {
          orderedKeys.add(_showTabKey);
          print('✅ [COMPREHENSIVE] Show tab available (11/13)');
        }
        
        if (_progressCardsKey.currentContext != null) {
          orderedKeys.add(_progressCardsKey);
          print('✅ [COMPREHENSIVE] Progress Cards available (12/13)');
        }
        
        if (_wellnessTipsShowKey.currentContext != null) {
          orderedKeys.add(_wellnessTipsShowKey);
          print('✅ [COMPREHENSIVE] Wellness Tips (Show) available (13/13)');
        }
        
        if (orderedKeys.isNotEmpty) {
          print('🚀 [COMPREHENSIVE] Starting automatic tour flow...');
          
          // Start the automatic tour flow
          _startAutomaticTour(context);
        } else {
          print('❌ [COMPREHENSIVE] No elements found, showing fallback dialog...');
          _showTourFallbackDialog(context);
        }
      } catch (e) {
        print('❌ [COMPREHENSIVE] Error accessing ShowCaseWidget: $e');
        _showTourFallbackDialog(context);
      }
    });
  }

  /// Fallback dialog if showcase fails
  static void _showTourFallbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welcome to Sea Smart! 🌊'),
        content: const Text('Explore the three main sections:\n\n• Know - SOAR assessments, goal setting, and wellness tips\n• Grow - Chat with AI buddy, activities, academy, and games\n• Show - Progress tracking and analytics'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  static void _startShowcaseViewTour(BuildContext context) {
    print('🚀 [SHOWCASE] Starting showcase tour...');
    _startComprehensiveTour(context);
  }

  /// Global keys for tour targets
  static final GlobalKey _knowTabKey = GlobalKey();
  static final GlobalKey _growTabKey = GlobalKey();
  static final GlobalKey _showTabKey = GlobalKey();
  static final GlobalKey _soarAssessmentKey = GlobalKey();
  static final GlobalKey _goalsKey = GlobalKey();
  static final GlobalKey _wellnessTipsKnowKey = GlobalKey();
  static final GlobalKey _chatWithBuddyKey = GlobalKey();
  static final GlobalKey _activitiesKey = GlobalKey();
  static final GlobalKey _academyKey = GlobalKey();
  static final GlobalKey _gamesKey = GlobalKey();
  static final GlobalKey _wellnessTipsGrowKey = GlobalKey();
  static final GlobalKey _progressCardsKey = GlobalKey();
  static final GlobalKey _wellnessTipsShowKey = GlobalKey();

  /// Get all tour keys
  static List<GlobalKey> get tourKeys => [
        _knowTabKey,
        _growTabKey,
        _showTabKey,
        _soarAssessmentKey,
        _goalsKey,
        _wellnessTipsKnowKey,
        _chatWithBuddyKey,
        _activitiesKey,
        _academyKey,
        _gamesKey,
        _wellnessTipsGrowKey,
        _progressCardsKey,
        _wellnessTipsShowKey,
      ];

  /// Get specific keys
  static GlobalKey get knowTabKey => _knowTabKey;
  static GlobalKey get growTabKey => _growTabKey;
  static GlobalKey get showTabKey => _showTabKey;
  static GlobalKey get soarAssessmentKey => _soarAssessmentKey;
  static GlobalKey get goalsKey => _goalsKey;
  static GlobalKey get wellnessTipsKnowKey => _wellnessTipsKnowKey;
  static GlobalKey get chatWithBuddyKey => _chatWithBuddyKey;
  static GlobalKey get activitiesKey => _activitiesKey;
  static GlobalKey get academyKey => _academyKey;
  static GlobalKey get gamesKey => _gamesKey;
  static GlobalKey get wellnessTipsGrowKey => _wellnessTipsGrowKey;
  static GlobalKey get progressCardsKey => _progressCardsKey;
  static GlobalKey get wellnessTipsShowKey => _wellnessTipsShowKey;
}

/// Tour step data class
class TourStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget? customWidget;

  const TourStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.customWidget,
  });
}

/// Tour step definitions
class TourSteps {
  static const List<TourStep> steps = [
    // Tab Navigation
    TourStep(
      title: "Welcome to Sea Smart! 🌊",
      description: "Let's explore the three main sections: Know, Grow, and Show. Each section helps you on your wellness journey at sea.",
      icon: Icons.explore,
      color: Color(0xFF3498DB),
    ),
    TourStep(
      title: "Know Tab 📚",
      description: "Click here to access your knowledge hub! Find SOAR assessments, set goals, and wellness tips.",
      icon: Icons.school,
      color: Color(0xFF9B59B6),
    ),
    TourStep(
      title: "Grow Tab 🌱",
      description: "Your activity center! Engage with games, breathing exercises, and activities to develop your wellness skills.",
      icon: Icons.psychology,
      color: Color(0xFF2ECC71),
    ),
    TourStep(
      title: "Show Tab 📊",
      description: "Click here to track your progress! View analytics, achievements, and see your wellness journey.",
      icon: Icons.analytics,
      color: Color(0xFFE67E22),
    ),
    // Know Tab Features
    TourStep(
      title: "SOAR Assessment 🎯",
      description: "Complete your wellness assessment to understand your strengths and growth areas.",
      icon: Icons.quiz,
      color: Color(0xFF9B59B6),
    ),
    TourStep(
      title: "Goal Setting 🎯",
      description: "Set and track your wellness goals for fitness, study, and personal growth.",
      icon: Icons.flag,
      color: Color(0xFF2ECC71),
    ),
    TourStep(
      title: "Wellness Tips 💡",
      description: "Access expert wellness tips and breathing techniques for life at sea.",
      icon: Icons.lightbulb,
      color: Color(0xFF3498DB),
    ),
    // Grow Tab Features
    TourStep(
      title: "Chat with Your Buddy 🤖",
      description: "Get personalized support from your AI wellness buddy anytime.",
      icon: Icons.chat,
      color: Color(0xFF3498DB),
    ),
    TourStep(
      title: "Wellness Activities 🧘",
      description: "Engage in meditation and breathing exercises for stress relief.",
      icon: Icons.self_improvement,
      color: Color(0xFF1ABC9C),
    ),
    TourStep(
      title: "Academy Learning 🎓",
      description: "Access professional consultations and educational content.",
      icon: Icons.school,
      color: Color(0xFFE67E22),
    ),
    TourStep(
      title: "Interactive Games 🎮",
      description: "Play calming games to improve focus and reduce stress.",
      icon: Icons.games,
      color: Color(0xFF9B59B6),
    ),
    // Show Tab Features
    TourStep(
      title: "Progress Tracking 📈",
      description: "View your wellness progress through journal entries and mood tracking.",
      icon: Icons.trending_up,
      color: Color(0xFF2ECC71),
    ),
    TourStep(
      title: "Mood Analytics 📊",
      description: "Analyze your mood patterns and wellness trends.",
      icon: Icons.analytics,
      color: Color(0xFF3498DB),
    ),
  ];
}
