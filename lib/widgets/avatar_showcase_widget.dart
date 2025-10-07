import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class AvatarShowcaseWidget extends StatelessWidget {
  final Widget child;
  final GlobalKey targetKey;
  final String title;
  final String description;
  final Color color;

  const AvatarShowcaseWidget({
    super.key,
    required this.child,
    required this.targetKey,
    required this.title,
    required this.description,
    this.color = const Color(0xFF3498DB),
  });

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: targetKey,
      title: title,
      description: description,
      tooltipBackgroundColor: color,
      textColor: Colors.white,
      tooltipBorderRadius: BorderRadius.circular(16),
      tooltipPadding: const EdgeInsets.all(16),
      titlePadding: const EdgeInsets.only(bottom: 8),
      descriptionPadding: EdgeInsets.zero,
      showArrow: true,
      disposeOnTap: false,
      tooltipPosition: _getTooltipPosition(),
      disableBarrierInteraction: false,
      onTargetClick: () {
        print('🎯 [TARGET_CLICK] Target clicked for element: $title');
      },
      onBarrierClick: () {
        print('🎯 [BARRIER_CLICK] Barrier clicked for element: $title');
      },
      child: child,
    );
  }

  TooltipPosition _getTooltipPosition() {
    if (title.contains('Tab') || 
        title.contains('Chat with Your AI Buddy') ||
        title.contains('Wellness Activities')) {
      return TooltipPosition.bottom;
    }
    return TooltipPosition.top;
  }
}