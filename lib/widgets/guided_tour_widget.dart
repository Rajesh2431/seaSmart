import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'avatar_dialogue_widget.dart';
import '../services/guided_tour_service.dart';
import '../services/user_avatar_service.dart';

class GuidedTourWidget extends StatelessWidget {
  final Widget child;
  final GlobalKey targetKey;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isFirst;
  final bool isLast;

  const GuidedTourWidget({
    super.key,
    required this.child,
    required this.targetKey,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isFirst = false,
    this.isLast = false,
  });

  TooltipPosition _getTooltipPosition() {
    // Position tooltip below for specific elements
    if (title.contains('Know Tab') || 
        title.contains('Show Tab') || 
        title.contains('Grow Tab') ||
        title.contains('Chat with Your AI Buddy') ||
        title.contains('Wellness Activities')) {
      return TooltipPosition.bottom;
    }
    // Default position (top) for all other elements
    return TooltipPosition.top;
  }

  @override
  Widget build(BuildContext context) {
    print('🎯 [GUIDED_TOUR] Building Showcase widget for: $title');
    print('🎯 [GUIDED_TOUR] Target key: $targetKey');
    print('🎯 [GUIDED_TOUR] Key has context: ${targetKey.currentContext != null}');
    
    return Showcase(
      key: targetKey,
      title: title,
      description: description,
      tooltipBackgroundColor: color,
      textColor: Colors.white,
      tooltipBorderRadius: BorderRadius.circular(16),
      tooltipPadding: const EdgeInsets.all(20),
      titlePadding: const EdgeInsets.only(bottom: 8),
      descriptionPadding: const EdgeInsets.only(bottom: 16),
      showArrow: true,
      disposeOnTap: false, // Don't auto-dispose, let user control
      tooltipPosition: _getTooltipPosition(),
      disableBarrierInteraction: false,
      onTargetClick: () {
        print('🎯 [TARGET_CLICK] Target clicked for element: $title');
        print('🎯 [TARGET_CLICK] Target key: $targetKey');
        // Allow showcase to proceed to next element
      },
      onBarrierClick: () {
        print('🎯 [BARRIER_CLICK] Barrier clicked for element: $title');
        print('🎯 [BARRIER_CLICK] Target key: $targetKey');
        // Don't start new tour - let manual tour handle progression
        print('🎯 [BARRIER_CLICK] Manual tour active, not starting new tour');
      },
      child: child,
    );
  }

  /// Method to trigger scroll when tour starts (called externally)
  static void startTourScrolling(BuildContext context) {
    print('🚀 [TOUR_SCROLL] Starting tour scrolling for all elements...');
    // This will be implemented in the guided tour service
  }

  void _scrollToElement(BuildContext context) {
    print('🎯 [SCROLL_METHOD] _scrollToElement called for: $title');
    print('🎯 [SCROLL_METHOD] Target key: $targetKey');
    print('🎯 [SCROLL_METHOD] Key has context: ${targetKey.currentContext != null}');
    
    try {
      final RenderBox? renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        // Find the nearest Scrollable ancestor
        final ScrollableState scrollable = Scrollable.of(context);
        final ScrollPosition position = scrollable.position;
        
        // Get the element's position relative to the viewport
        final Offset globalPosition = renderBox.localToGlobal(Offset.zero);
        final double elementTop = globalPosition.dy;
        final double viewportHeight = MediaQuery.of(context).size.height;
        final double appBarHeight = 100; // Account for app bar
        
         // Debug logging
        print('🔍 [DEBUG] Before Scroll calculations for: $title');
        print('🔍 [DEBUG] Before Current position.pixels: ${position.pixels}');
        print('🔍 [DEBUG] Before Element top position: $elementTop');
        print('🔍 [DEBUG] Before Viewport height: $viewportHeight');
        print('🔍 [DEBUG] Before App bar height: $appBarHeight');
        
        // Get actual section position in pixels
        final double actualSectionTop = globalPosition.dy;
        final double actualSectionBottom = actualSectionTop + renderBox.size.height;
        final double actualSectionCenter = actualSectionTop + (renderBox.size.height / 2);
        
        print('📍 [SECTION_POSITION] [DEBUG] Actual section top: $actualSectionTop px');
        print('📍 [SECTION_POSITION] [DEBUG] Actual section bottom: $actualSectionBottom px');
        print('📍 [SECTION_POSITION] [DEBUG] Actual section center: $actualSectionCenter px');
        print('📍 [SECTION_POSITION] [DEBUG] Section height: ${renderBox.size.height} px');
        
        // Check if this is a tab element that should be at position 208
        final bool isTabElement = title.contains('Tab');
        if (isTabElement) {
          print('🔍 [DEBUG] This is a TAB element - should be at position 208');
        }

        // Calculate how much to scroll to position element properly
       
        final double targetScroll;
        if (isTabElement) {
          // Tab elements should stay at their natural position (208)
          // Don't scroll for tab elements, just ensure they're visible
          targetScroll = position.pixels;
          print('🔍 [DEBUG] TAB element detected - keeping current scroll position');
        } else if (title.contains('Chat with Your AI Buddy')) {
          // Don't scroll for Chat with AI Buddy - keep current position
          targetScroll = position.pixels;
          print('🔍 [DEBUG] Chat with AI Buddy detected - keeping current scroll position');
        } else {
          // Element is below, center it in viewport
          targetScroll = position.pixels + (elementTop - (viewportHeight / 2) - appBarHeight);
          print('🔍 [DEBUG] Element below fold - centering in viewport');
        }
        
        // Ensure we don't scroll beyond bounds
        final double maxScroll = position.maxScrollExtent;
        final double finalPosition = targetScroll.clamp(0.0, maxScroll);
        
        // Debug logging for scroll calculations
        print('🔍 [DEBUG] Target scroll: $targetScroll');
        print('🔍 [DEBUG] Max scroll extent: $maxScroll');
        print('🔍 [DEBUG] Final position: $finalPosition');
        
        // Calculate where the highlight will be positioned after scroll
        final double highlightTopAfterScroll = actualSectionTop - finalPosition;
        final double highlightCenterAfterScroll = actualSectionCenter - finalPosition;
        final double highlightBottomAfterScroll = actualSectionBottom - finalPosition;
        
        print('🎯 [HIGHLIGHT_POSITION] [DEBUG] Highlight top after scroll: $highlightTopAfterScroll px');
        print('🎯 [HIGHLIGHT_POSITION] [DEBUG]Highlight center after scroll: $highlightCenterAfterScroll px');
        print('🎯 [HIGHLIGHT_POSITION] [DEBUG]Highlight bottom after scroll: $highlightBottomAfterScroll px');
        
        // Interactive debug console - you can modify these values
        print('🔧 [DEBUG_CONSOLE] =================================');
        print('🔧 [DEBUG_CONSOLE] MANUAL HIGHLIGHT POSITION OVERRIDE');
        print('🔧 [DEBUG_CONSOLE] =================================');
        print('🔧 [DEBUG_CONSOLE] Current calculated final position: $finalPosition');
        print('🔧 [DEBUG_CONSOLE] To override, modify the line below:');
        print('🔧 [DEBUG_CONSOLE] double manualFinalPosition = $finalPosition; // ← Change this value');
        print('🔧 [DEBUG_CONSOLE] =================================');
        
        // MANUAL OVERRIDE - Change this value to test different positions
        double manualFinalPosition = finalPosition; // ← CHANGE THIS VALUE FOR DEBUGGING
        

        // Example manual positions (uncomment to test):
        // double manualFinalPosition = 0; // Scroll to top
        // double manualFinalPosition = 200; // Scroll to 200px
        // double manualFinalPosition = actualSectionTop - 208; // Position section at 208px
        // double manualFinalPosition = actualSectionTop - 300; // Position section at 300px
        
        final double clampedManualPosition = manualFinalPosition.clamp(0.0, maxScroll);
        print('🔧 [DEBUG_CONSOLE] Using manual position: $clampedManualPosition');
        
        // Log debug info immediately, not after scroll
        print('🎯 [IMMEDIATE_DEBUG] Current element being processed: $title');
        print('🎯 [IMMEDIATE_DEBUG] Target position: $clampedManualPosition');
        print('🎯 [IMMEDIATE_DEBUG] Element top: $actualSectionTop px');
        print('🎯 [IMMEDIATE_DEBUG] Element bottom: ${actualSectionTop + renderBox.size.height} px');
        print('🎯 [IMMEDIATE_DEBUG] Element center: ${actualSectionTop + (renderBox.size.height / 2)} px');
        
        // Scroll to position the content
        position.animateTo(
          clampedManualPosition,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
        print('🎯 [GUIDED_TOUR] Scrolled to element: $title at MANUAL position $clampedManualPosition');
            }
    } catch (e) {
      print('❌ [GUIDED_TOUR] Error scrolling to element: $e');
    }
  }

}

/// Tour trigger button widget
class TourTriggerButton extends StatelessWidget {
  const TourTriggerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: GuidedTourService.hasCompletedTour(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        
        final hasCompleted = snapshot.data ?? false;
        
        if (hasCompleted) {
          return IconButton(
            onPressed: () => _showTourOptions(context),
            icon: const Icon(Icons.help_outline),
            tooltip: 'Tour Options',
          );
        } else {
          return FloatingActionButton(
            onPressed: () => _startTour(context),
            backgroundColor: const Color(0xFF3498DB),
            tooltip: 'Take Tour',
            child: const Icon(Icons.tour, color: Colors.white),
          );
        }
      },
    );
  }

  void _startTour(BuildContext context) {
    print('🚀 [TOUR_TRIGGER] Tour button clicked!');
    print('🚀 [TOUR_TRIGGER] Starting tour...');
    
    // Use the showcaseview tour
    GuidedTourService.startTour(context);
  }

  void _showTourOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tour Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.tour, color: Color(0xFF3498DB)),
                title: const Text('Take Guided Tour Again'),
                subtitle: const Text('Revisit the tour to refresh your memory'),
                onTap: () {
                  Navigator.pop(context);
                  GuidedTourService.startTour(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.help, color: Color(0xFF9B59B6)),
                title: const Text('Help & Support'),
                subtitle: const Text('Get help with using the app'),
                onTap: () {
                  Navigator.pop(context);
                  _showHelpDialog(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help, color: Color(0xFF9B59B6)),
            SizedBox(width: 8),
            Text('Help & Support'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Sea Smart has three main sections:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('📚 Know - Assessments, goals, and wellness tips'),
              Text('🌱 Grow - Activities, games, and learning'),
              Text('📊 Show - Progress tracking and analytics'),
              SizedBox(height: 16),
              Text(
                'Need more help? Contact support or take the guided tour again!',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              GuidedTourService.startTour(context);
            },
            child: const Text('Take Tour'),
          ),
        ],
      ),
    );
  }
}
