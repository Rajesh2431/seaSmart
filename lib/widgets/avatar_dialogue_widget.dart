import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class AvatarDialogueWidget extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onSkip;
  final bool showSkipButton;
  final Color backgroundColor;
  final Color textColor;

  const AvatarDialogueWidget({
    super.key,
    required this.title,
    required this.description,
    this.onSkip,
    this.showSkipButton = false,
    this.backgroundColor = const Color(0xFF3498DB),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar section
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          // Content section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: textColor.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                if (showSkipButton && onSkip != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: textColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar showcase widget for specialized avatar elements
class AvatarShowcaseWidget extends StatelessWidget {
  final Widget child;
  final GlobalKey targetKey;
  final String title;
  final String description;
  final VoidCallback? onSkip;
  final bool showSkipButton;

  const AvatarShowcaseWidget({
    super.key,
    required this.child,
    required this.targetKey,
    required this.title,
    required this.description,
    this.onSkip,
    this.showSkipButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: targetKey,
      title: title,
      description: description,
      targetShapeBorder: const CircleBorder(),
      targetBorderRadius: BorderRadius.circular(25),
      tooltipBackgroundColor: const Color(0xFF3498DB),
      textColor: Colors.white,
      tooltipPosition: TooltipPosition.bottom,
      onTargetClick: () {
        print('🎯 [AVATAR_SHOWCASE] Avatar clicked: $title');
      },
      child: child,
    );
  }
}
