import 'package:flutter/material.dart';
import 'avatar_dialogue_widget.dart';

class CustomTourOverlay extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final String? title;
  final String? description;
  final VoidCallback? onSkip;
  final bool showSkipButton;
  final GlobalKey? targetKey;
  final DialoguePosition tooltipPosition;

  const CustomTourOverlay({
    super.key,
    required this.child,
    this.isActive = false,
    this.title,
    this.description,
    this.onSkip,
    this.showSkipButton = false,
    this.targetKey,
    this.tooltipPosition = DialoguePosition.bottom,
  });

  @override
  State<CustomTourOverlay> createState() => _CustomTourOverlayState();
}

class _CustomTourOverlayState extends State<CustomTourOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isActive && widget.title != null && widget.description != null)
          _buildOverlay(),
      ],
    );
  }

  Widget _buildOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Stack(
        children: [
          // Cutout for the target element
          if (widget.targetKey?.currentContext != null)
            _buildCutout(),
          
          // Custom dialogue tooltip
          _buildDialogueTooltip(),
        ],
      ),
    );
  }

  Widget _buildCutout() {
    return Positioned.fill(
      child: CustomPaint(
        painter: CutoutPainter(
          targetKey: widget.targetKey!,
          context: context,
        ),
      ),
    );
  }

  Widget _buildDialogueTooltip() {
    // Calculate position for the tooltip
    final RenderBox? renderBox = widget.targetKey?.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    // Calculate tooltip position based on tooltipPosition
    Offset tooltipOffset;
    switch (widget.tooltipPosition) {
      case DialoguePosition.top:
        tooltipOffset = Offset(
          position.dx + (size.width / 2) - 140, // Center horizontally
          position.dy - 120, // Above the target
        );
        break;
      case DialoguePosition.bottom:
        tooltipOffset = Offset(
          position.dx + (size.width / 2) - 140, // Center horizontally
          position.dy + size.height + 20, // Below the target
        );
        break;
      case DialoguePosition.left:
        tooltipOffset = Offset(
          position.dx - 300, // To the left
          position.dy + (size.height / 2) - 60, // Center vertically
        );
        break;
      case DialoguePosition.right:
        tooltipOffset = Offset(
          position.dx + size.width + 20, // To the right
          position.dy + (size.height / 2) - 60, // Center vertically
        );
        break;
    }

    // Ensure tooltip stays within screen bounds
    tooltipOffset = Offset(
      tooltipOffset.dx.clamp(10, screenSize.width - 290),
      tooltipOffset.dy.clamp(10, screenSize.height - 150),
    );

    return Positioned(
      left: tooltipOffset.dx,
      top: tooltipOffset.dy,
      child: AvatarDialogueWidget(
        title: widget.title!,
        description: widget.description!,
        onSkip: widget.onSkip,
        showSkipButton: widget.showSkipButton,
      ),
    );
  }
}

class CutoutPainter extends CustomPainter {
  final GlobalKey targetKey;
  final BuildContext context;

  CutoutPainter({required this.targetKey, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox? renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;

    // Create a path that covers the entire screen
    final Path path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create a circular cutout for the target element
    final Path cutout = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
          position.dx - 5,
          position.dy - 5,
          targetSize.width + 10,
          targetSize.height + 10,
        ),
        const Radius.circular(8),
      ));

    // Subtract the cutout from the path
    final Path finalPath = Path.combine(PathOperation.difference, path, cutout);

    // Paint the overlay
    final Paint paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

enum DialoguePosition { top, bottom, left, right }
