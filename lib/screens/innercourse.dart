import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import '../services/content_service.dart';

class InnerCourse extends StatefulWidget {
  final String courseTitle;
  final String? userEmail;

  const InnerCourse({super.key, required this.courseTitle, this.userEmail});

  @override
  State<InnerCourse> createState() => _InnerCourseState();
}

class _InnerCourseState extends State<InnerCourse>
    with TickerProviderStateMixin {
  late AnimationController _particleAnimationController;

  @override
  void initState() {
    super.initState();
    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _particleAnimationController.dispose();
    super.dispose();
  }

  /// Check if this is a loneliness course
  bool _isLonelinessCourse() {
    final title = widget.courseTitle.toLowerCase();
    return title.contains('loneliness') || title.contains('lonely');
  }

  /// Navigate to external academy website for loneliness courses
  Future<void> _navigateToAcademy() async {
    try {
      await ContentService.launchAcademyWebsite();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening Loneliness Academy...'),
            backgroundColor: Color(0xFF3B82F6),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening academy: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigate to external website
  Future<void> _navigateToWebsite() async {
    try {
      await ContentService.launchAcademyWebsite();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening course website...'),
            backgroundColor: Color(0xFF3B82F6),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening website: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateCertificate() async {
    // For loneliness courses, navigate to external academy first
    if (_isLonelinessCourse()) {
      await _navigateToAcademy();
      return;
    }

    if (widget.userEmail == null || widget.userEmail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User email not found. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Generating certificate..."),
              ],
            ),
          );
        },
      );

      const endpoint =
          'https://strivehigh.thirdvizion.com/api/generatecertificate/';
      bool success = false;
      dynamic responseData;

      try {
        final requestData = {
          'email': widget.userEmail,
          'category': widget.courseTitle,
        };
        final response = await http.post(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestData),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          try {
            responseData = json.decode(response.body);
            success = true;
          } catch (e) {
            // Failed to parse response
          }
        }
      } catch (e) {
        // Error with API call
      }

      // Close loading dialog
      Navigator.of(context).pop();

      if (success) {
        _showCelebrationDialog();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Certificate Generation Failed'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Course: ${widget.courseTitle}'),
                  Text('Email: ${widget.userEmail}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to generate certificate. Please try again later or contact support if the issue persists.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating certificate: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.courseTitle,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.blue),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF21A2D0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.courseTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Professional Development Course",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Course Overview Section
              const Text(
                "Course Overview",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  "Welcome to the ${widget.courseTitle} course. This comprehensive course will help you understand and develop skills in this important area. Our expert-designed curriculum covers all the essential topics and provides practical knowledge you can apply immediately.",
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Course Features
              const Text(
                "What You'll Learn",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.check_circle_outline,
                title: "Expert Content",
                description: "Learn from industry professionals",
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.timer_outlined,
                title: "Self-Paced Learning",
                description: "Study at your own convenience",
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.workspace_premium_outlined,
                title: "Certificate of Completion",
                description: "Earn recognition for your achievement",
              ),
              const SizedBox(height: 32),

              // Action Buttons
              isSmallScreen
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _generateCertificate,
                            icon: Icon(
                              _isLonelinessCourse()
                                  ? Icons.launch
                                  : Icons.check_circle,
                              color: Colors.white,
                            ),
                            label: Text(
                              _isLonelinessCourse()
                                  ? "Start Course"
                                  : "Mark as Completed",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _navigateToWebsite,
                            icon: const Icon(
                              Icons.language,
                              color: Colors.blue,
                            ),
                            label: const Text(
                              "Visit Course Website",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _generateCertificate,
                            icon: Icon(
                              _isLonelinessCourse()
                                  ? Icons.launch
                                  : Icons.check_circle,
                              color: Colors.white,
                            ),
                            label: Text(
                              _isLonelinessCourse()
                                  ? "Start Course"
                                  : "Mark as Completed",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _navigateToWebsite,
                            icon: const Icon(
                              Icons.language,
                              color: Colors.blue,
                            ),
                            label: const Text(
                              "Website",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 24),

              // Additional Resources Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.folder_open,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Additional Resources",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildResourceItem("Course Materials", Icons.download),
                    _buildResourceItem("Discussion Forum", Icons.forum),
                    _buildResourceItem("Help & Support", Icons.help),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 28),
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
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem(String title, IconData icon) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $title...'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade600, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showCelebrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        final dialogWidth = screenSize.width * 0.9;
        final dialogHeight = math.min(screenSize.height * 0.7, 500.0);

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: dialogWidth,
            height: dialogHeight,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4CAF50),
                  Color(0xFF81C784),
                  Color(0xFF66BB6A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _particleAnimationController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ConfettiPainter(
                          animation: _particleAnimationController,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Colors.amber, Colors.orange],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.bounceOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: const Text(
                                '🎉 CONGRATULATIONS! 🎉',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: const Text(
                                'Certificate Earned!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1400),
                        curve: Curves.easeOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 40 * (1 - value)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: Text(
                                  widget.courseTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1600),
                          curve: Curves.elasticOut,
                          builder: (context, double value, child) {
                            return Transform.scale(
                              scale: value,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF4CAF50),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  ConfettiPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
    ];

    for (int i = 0; i < 30; i++) {
      final progress = (animation.value + i * 0.1) % 1.0;
      final y = (progress * size.height * 1.5 - size.height * 0.2).toDouble();
      final sinValue = math.sin(
        (progress.toDouble() * math.pi * 4 + i.toDouble()).toDouble(),
      );
      final x =
          (size.width * 0.1 +
                  (i.toDouble() * size.width * 0.8 / 30) +
                  (sinValue * 50).toDouble())
              .toDouble();

      if (y > -20 && y < size.height + 20) {
        final color = colors[i % colors.length];
        final paint = Paint()
          ..color = color.withOpacity((0.8 - progress * 0.6).toDouble())
          ..style = PaintingStyle.fill;
        final shapeType = i % 4;
        final particleSize = 6.0 + random.nextDouble() * 8;

        if (shapeType == 0) {
          canvas.drawCircle(Offset(x, y), particleSize / 2, paint);
        } else if (shapeType == 1) {
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(x, y),
              width: particleSize,
              height: particleSize * 0.6,
            ),
            paint,
          );
        } else if (shapeType == 2) {
          final path = Path()
            ..moveTo(x, y - particleSize / 2)
            ..lineTo(x - particleSize / 2, y + particleSize / 2)
            ..lineTo(x + particleSize / 2, y + particleSize / 2)
            ..close();
          canvas.drawPath(path, paint);
        } else {
          final path = Path()
            ..moveTo(x, y - particleSize / 2)
            ..lineTo(x + particleSize / 4, y - particleSize / 4)
            ..lineTo(x + particleSize / 2, y)
            ..lineTo(x + particleSize / 4, y + particleSize / 4)
            ..lineTo(x, y + particleSize / 2)
            ..lineTo(x - particleSize / 4, y + particleSize / 4)
            ..lineTo(x - particleSize / 2, y)
            ..lineTo(x - particleSize / 4, y - particleSize / 4)
            ..close();
          canvas.drawPath(path, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
