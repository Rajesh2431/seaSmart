import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SoarPdfGenerator {
  static const Map<String, Map<String, String>> scoreRanges = {
    "90-100": {
      "title": "Exceptional Resilience",
      "feedback":
          "You demonstrate exceptional resilience, handling extreme stress and challenges with remarkable composure and effectiveness at sea. Your advanced coping strategies make you an invaluable asset to your crew and vessel. Continue refining these skills to maintain peak performance in the most demanding maritime conditions.",
    },
    "80-89": {
      "title": "Very Strong Resilience",
      "feedback":
          "You exhibit very strong resilience, managing high levels of stress effectively while maintaining professional performance. Your coping mechanisms are well-developed and serve you excellently in challenging maritime environments. Keep building on these strengths to reach exceptional levels.",
    },
    "70-79": {
      "title": "Strong Resilience",
      "feedback":
          "You show strong resilience with effective stress management and emotional regulation skills. Your ability to handle maritime challenges is commendable, with good potential for further development. Continue practicing and exploring advanced coping strategies to enhance your capabilities.",
    },
    "60-69": {
      "title": "Good Resilience",
      "feedback":
          "You have good resilience skills that help you manage moderate stress and maintain performance at sea. Your coping strategies are functional, but there's room to develop more sophisticated techniques. Focus on building emotional regulation and stress management tools for better outcomes.",
    },
    "50-59": {
      "title": "Moderate Resilience",
      "feedback":
          "Your resilience is at a moderate level, with basic stress management skills in place. You can handle routine challenges effectively, but higher stress situations may require additional coping strategies. Invest time in developing stronger emotional regulation and support networks.",
    },
    "40-49": {
      "title": "Developing Resilience",
      "feedback":
          "You're developing resilience skills with a foundation in stress management. While you can manage some challenges, there's significant potential for growth. Focus on learning new coping techniques, building support systems, and practicing emotional regulation to strengthen your maritime performance.",
    },
    "30-39": {
      "title": "Limited Resilience",
      "feedback":
          "Your resilience is limited, and stress management needs attention. You may struggle with moderate challenges at sea, requiring better coping strategies. Seek training in stress management techniques and consider building stronger support networks to improve your resilience.",
    },
    "20-29": {
      "title": "Low Resilience",
      "feedback":
          "Resilience is low, indicating a need for significant development in stress management and emotional regulation. Maritime environments can be particularly challenging for you currently. Focus on basic coping skills, seek professional support, and build resilience gradually through practice.",
    },
    "10-19": {
      "title": "Very Low Resilience",
      "feedback":
          "Resilience is very low, requiring substantial development. Stress and challenges at sea may significantly impact your performance and well-being. This is an opportunity to start building essential skills - begin with basic stress management techniques and seek guidance to establish a strong foundation.",
    },
    "0-9": {
      "title": "Needs Development",
      "feedback":
          "Resilience needs considerable development. Current levels suggest significant challenges in managing stress and maintaining composure at sea. Start with fundamental coping strategies, seek professional support, and commit to gradual improvement through consistent practice and learning.",
    },
  };

  static String _getScoreRange(int percentage) {
    if (percentage >= 90) return "90-100";
    if (percentage >= 80) return "80-89";
    if (percentage >= 70) return "70-79";
    if (percentage >= 60) return "60-69";
    if (percentage >= 50) return "50-59";
    if (percentage >= 40) return "40-49";
    if (percentage >= 30) return "30-39";
    if (percentage >= 20) return "20-29";
    if (percentage >= 10) return "10-19";
    return "0-9";
  }

  static const List<PdfColor> percentageColors = [
    PdfColor(0.8, 0, 0), // Red for 0-9
    PdfColor(0.8, 0.4, 0), // Orange for 10-19
    PdfColor(0.8, 0.8, 0), // Yellow for 20-29
    PdfColor(0.4, 0.8, 0), // Lime for 30-39
    PdfColor(0, 0.8, 0), // Green for 40-49
    PdfColor(0, 0.8, 0.4), // Cyan for 50-59
    PdfColor(0, 0.4, 0.8), // Sky for 60-69
    PdfColor(0, 0, 0.8), // Blue for 70-79
    PdfColor(0.4, 0, 0.8), // Purple for 80-89
    PdfColor(0.8, 0, 0.8), // Magenta for 90-99
    PdfColor(0.4, 0.4, 0.4), // Grey for 100
  ];

  static PdfColor _getProgressBarColor(int percentage) {
    int index = percentage ~/ 10;
    if (index > 10) index = 10;
    return percentageColors[index];
  }

  static String _getFeedbackText(int percentage) {
    if (percentage >= 80) return "Excellent performance!";
    if (percentage >= 60) return "Good progress, keep it up!";
    if (percentage >= 40) return "Focus on improving";
    if (percentage >= 20) return "Needs attention";
    return "Requires development";
  }

  static String _getOverallInsight(double avgScore) {
    if (avgScore >= 80) {
      return "Excellent performance! You're showing strong competency across all areas.";
    } else if (avgScore >= 60) {
      return "Good progress! You're developing well with room for continued growth.";
    } else if (avgScore >= 40) {
      return "You're on the right track! Focus on the areas that need attention.";
    } else {
      return "Great start! Every journey begins with the first step.";
    }
  }

  static Map<String, dynamic> _getPerformanceLevel(int percentage) {
    if (percentage >= 80) {
      return {
        'title': 'Excellent',
        'description': 'Outstanding performance across all competencies',
        'color': PdfColor(76/255, 175/255, 80/255),
      };
    } else if (percentage >= 60) {
      return {
        'title': 'Good',
        'description': 'Strong foundation with areas for growth',
        'color': PdfColor(33/255, 150/255, 243/255),
      };
    } else if (percentage >= 40) {
      return {
        'title': 'Developing',
        'description': 'Good progress with focused improvement needed',
        'color': PdfColor(255/255, 152/255, 0/255),
      };
    } else {
      return {
        'title': 'Beginning',
        'description': 'Starting your development journey',
        'color': PdfColor(244/255, 67/255, 54/255),
      };
    }
  }

  static Future<void> generateAndDownloadPdf({
    required String userEmail,
    required String userName,
    required List<Map<String, dynamic>> categoryWise,
    required List<double> overallAvg,
    required BuildContext context,
  }) async {
    try {
      // Platform-specific permissions handling
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 32) {
          final permission = await Permission.storage.request();
          if (permission != PermissionStatus.granted) {
            final manageStorage =
                await Permission.manageExternalStorage.request();
            if (manageStorage != PermissionStatus.granted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Storage permission is required to save PDF. Please enable it in app settings.',
                  ),
                  duration: Duration(seconds: 5),
                ),
              );
              await openAppSettings();
              return;
            }
          }
        }
      } else if (Platform.isIOS) {
        // iOS doesn't require explicit storage permissions for app documents
        // Files are saved to app's documents directory automatically
        print('iOS: PDF will be saved to app documents directory');
      }

      final pdf = pw.Document();

      // Remove additional categories beyond the first 11
      if (categoryWise.length > 11) {
        categoryWise.removeRange(11, categoryWise.length);
      }

      // Set percentages from overallAvg
      for (int i = 0; i < categoryWise.length && i < overallAvg.length; i++) {
        categoryWise[i]["percentage"] = overallAvg[i];
      }

      final avgScore = categoryWise.isNotEmpty
          ? categoryWise.map((e) => (e["percentage"] as double?) ?? 0.0).reduce((a, b) => a + b) /
              categoryWise.length
          : 0.0;
      final maxValue = categoryWise.isNotEmpty
          ? categoryWise
              .map((e) => (e["percentage"] as double?) ?? 0.0)
              .reduce((a, b) => a > b ? a : b)
          : 0.0;
      final percentage = maxValue > 0 ? (avgScore / maxValue * 100).round() : 0;
      final level = _getPerformanceLevel(percentage);

      // Page 1: Header, Overall Summary, Pie Chart
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),
                _buildPdfHeader(userName, userEmail),
                pw.SizedBox(height: 20),
                _buildOverallSummary(avgScore, maxValue, percentage, level),
                pw.SizedBox(height: 20),
                _buildPieChart(categoryWise),
              ],
            );
          },
        ),
      );

      // Page 2: Category Breakdown
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildCategoryBreakdown(categoryWise),
              ],
            );
          },
        ),
      );

      // Page 3+: Detailed Feedback
      final feedbackItems = categoryWise.map((item) {
        final category = item["category"] as String;
        final score = (item["percentage"] as double?) ?? 0.0;
        final percentage = score.round();
        final scoreRange = _getScoreRange(percentage);
        final feedback = scoreRanges[scoreRange] ?? scoreRanges["0-9"]!;

        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 15),
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 12,
                    height: 12,
                    decoration: pw.BoxDecoration(
                      color: _getProgressBarColor(percentage),
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    category.split('(')[0].trim(),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    '$percentage% - ${_getFeedbackText(percentage)}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                feedback["title"]!,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                feedback["feedback"]!,
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                  lineSpacing: 1.4,
                ),
              ),
            ],
          ),
        );
      }).toList();

      // Add feedback pages (4 items per page)
      const int itemsPerPage = 4;
      for (int i = 0; i < feedbackItems.length; i += itemsPerPage) {
        final endIndex = (i + itemsPerPage < feedbackItems.length) ? i + itemsPerPage : feedbackItems.length;
        final pageItems = feedbackItems.sublist(i, endIndex);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (i == 0) ...[
                    pw.Text(
                      'Detailed Assessment Feedback',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 20),
                  ],
                  ...pageItems,
                ],
              );
            },
          ),
        );
      }

      // Final Page: Footer
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildPdfFooter(),
              ],
            );
          },
        ),
      );

      await _savePdf(pdf, context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  static pw.Widget _buildPdfHeader(String userName, String userEmail) {
    final displayName = userName.isNotEmpty ? userName : userEmail.split('@').first;

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF1976D2),
        borderRadius: pw.BorderRadius.circular(15),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 50,
            height: 50,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF1976D2),
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 15),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SOAR Analysis Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Strength, Opportunities, Aspirations & Recommendations',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Name: $displayName',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Email: $userEmail',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Generated on: ${DateTime.now().toString().substring(0, 16)}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOverallSummary(
    double avgScore,
    double maxValue,
    int percentage,
    Map<String, dynamic> level,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 60,
                height: 60,
                decoration: pw.BoxDecoration(
                  color: level['color'] as PdfColor,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text(
                    '$percentage%',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Overall Performance: ${level['title']}',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      level['description'] as String,
                      style: const pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              _getOverallInsight(avgScore),
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.blue800),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCategoryBreakdown(
    List<Map<String, dynamic>> categoryWise,
  ) {
    // Sort categories by percentage descending (high to low)
    final sortedCategories = List<Map<String, dynamic>>.from(categoryWise)
      ..sort((a, b) => ((b["percentage"] as double?) ?? 0.0).compareTo((a["percentage"] as double?) ?? 0.0));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Category Performance Overview',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 15),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: sortedCategories.map((item) {
              final category = item["category"] as String;
              final score = (item["percentage"] as double?) ?? 0.0;
              final percentage = score.round();

              const double progressAreaWidth = 150.0;
              final filledWidth = (percentage / 100) * progressAreaWidth;

              return pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey200),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        category.split('(')[0].trim(),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Container(
                      width: progressAreaWidth,
                      height: 8,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Stack(
                        children: [
                          pw.Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: pw.Container(
                              width: filledWidth,
                              height: 8,
                              decoration: pw.BoxDecoration(
                                color: _getProgressBarColor(percentage),
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Container(
                      width: 40,
                      child: pw.Text(
                        '$percentage%',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPieChart(List<Map<String, dynamic>> categoryWise) {
    if (categoryWise.isEmpty) {
      return pw.SizedBox.shrink();
    }

    // Sort categories by percentage descending
    final sortedCategories = List<Map<String, dynamic>>.from(categoryWise)
      ..sort((a, b) => ((b["percentage"] as double?) ?? 0.0).compareTo((a["percentage"] as double?) ?? 0.0));

    final total = sortedCategories.fold<double>(0.0, (sum, item) => sum + ((item["percentage"] as double?) ?? 0.0));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Pie chart and legend side by side
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Donut chart
            pw.Stack(
              children: [
                pw.Container(
                  width: 220,
                  height: 220,
                  child: pw.CustomPaint(
                    size: const PdfPoint(220, 220),
                    painter: (PdfGraphics pdfContext, PdfPoint size) {
                      final centerX = size.x / 2;
                      final centerY = size.y / 2;
                      final outerRadius = math.min(size.x, size.y) / 2 - 5;
                      final innerRadius = outerRadius * 0.6; // Donut hole radius
                      double currentAngle = -math.pi / 2; // Start from top (12 o'clock)

                      for (int i = 0; i < sortedCategories.length; i++) {
                        final percentage = (sortedCategories[i]["percentage"] as double?) ?? 0.0;
                        final sweepAngle = (percentage / total) * 2 * math.pi;
                        final color = _getProgressBarColor(percentage.round());

                        // Set fill color
                        pdfContext.setFillColor(color);

                        // Start from inner arc start point
                        final startAngle = currentAngle;
                        final endAngle = currentAngle + sweepAngle;

                        // Move to outer arc start point
                        pdfContext.moveTo(
                          centerX + outerRadius * math.cos(startAngle),
                          centerY + outerRadius * math.sin(startAngle),
                        );

                        // Draw outer arc
                        final segments = math.max(1, (sweepAngle * 30 / math.pi).round());
                        for (int j = 0; j <= segments; j++) {
                          final angle = startAngle + (sweepAngle * j / segments);
                          final x = centerX + outerRadius * math.cos(angle);
                          final y = centerY + outerRadius * math.sin(angle);
                          pdfContext.lineTo(x, y);
                        }

                        // Draw line to inner arc end point
                        pdfContext.lineTo(
                          centerX + innerRadius * math.cos(endAngle),
                          centerY + innerRadius * math.sin(endAngle),
                        );

                        // Draw inner arc back to start
                        for (int j = segments; j >= 0; j--) {
                          final angle = startAngle + (sweepAngle * j / segments);
                          final x = centerX + innerRadius * math.cos(angle);
                          final y = centerY + innerRadius * math.sin(angle);
                          pdfContext.lineTo(x, y);
                        }

                        // Close path and fill
                        pdfContext.fillPath();

                        currentAngle += sweepAngle;
                      }

                      // Draw white circle in center for donut hole
                      pdfContext
                        ..setFillColor(PdfColors.white)
                        ..drawEllipse(centerX, centerY, innerRadius, innerRadius)
                        ..fillPath();

                      // Draw white border around outer edge
                      pdfContext
                        ..setStrokeColor(PdfColors.white)
                        ..setLineWidth(3)
                        ..drawEllipse(centerX, centerY, outerRadius, outerRadius)
                        ..strokePath();
                    },
                  ),
                ),
                pw.Positioned(
                  left: 70,
                  top: 100,
                  child: pw.Text(
                    'SOAR Analysis',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(width: 25),

            // Legend on the right side
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: sortedCategories.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final category = item["category"] as String;
                  final percentage = ((item["percentage"] as double?) ?? 0.0).round();

                  final legendColor = _getProgressBarColor(percentage);

                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 16,
                          height: 16,
                          decoration: pw.BoxDecoration(
                            color: legendColor,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Expanded(
                          child: pw.Text(
                            category.split('(')[0].trim(),
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          '$percentage%',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPdfFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Powered by StriveHigh',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'This assessment is designed to help you understand your current competency levels and identify areas for growth.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Future<void> _savePdf(pw.Document pdf, BuildContext context) async {
    try {
      final output = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File("${output.path}/SOAR_Assessment_Report_$timestamp.pdf");
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF generated successfully!'),
          action: SnackBarAction(
            label: 'Share',
            onPressed: () => Share.shareXFiles([XFile(file.path)]),
          ),
        ),
      );

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My SOAR Assessment Report',
        subject: 'SOAR Assessment Report',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving PDF: $e')),
      );
    }
  }
}