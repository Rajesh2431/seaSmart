import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../services/user_profile_service.dart';
import 'soar_pdf_generator.dart';
import 'goalinfo_screen.dart';

class SoarDashboardPage extends StatefulWidget {
  final String userEmail;

  const SoarDashboardPage({super.key, required this.userEmail});

  @override
  State<SoarDashboardPage> createState() => _SoarDashboardPageState();
}

class _SoarDashboardPageState extends State<SoarDashboardPage> {
  bool _isLoading = true;
  String? _error;

  String? _userName;
  String? _userEmail;
  List<double> overallAvg = [];
  List<Map<String, dynamic>> categoryWise = [];
  List<Map<String, dynamic>> quizCategories = [];

  // Predefined categories list
  final List<String> predefinedCategories = [
    "Communication & influencing (Emotional Openness )",
    "Situation Awareness",
    "Teamwork",
    "Result Focus (Professional Development & Compliance)",
    "Leadership",
    "Stress management",
    "Decision making",
    "Crew Relationships",
    "Help-Seeking",
    "Empathy",
    "Command Pressure",
    "Additional Category 1",
    "Additional Category 2",
    "Additional Category 3",
    "Additional Category 4",
    "Additional Category 5",
    "Additional Category 6",
  ];

  // Score ranges and feedback content from the document
  final Map<String, Map<String, String>> scoreRanges = {
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

  // Track expanded state for each category
  final Map<String, bool> _expandedCategories = {};

  // Cache AI responses to prevent unnecessary refreshes
  final Map<String, String> _aiResponseCache = {};

  @override
  void initState() {
    super.initState();
    _fetchSoarCardDetails();
  }

  /// Refresh SOAR card data - useful for pull-to-refresh or manual refresh
  /// This will fetch the first 12 quiz answers for the user
  Future<void> refreshSoarData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _fetchSoarCardDetails();
  }

  /// Fetch quiz data from the correct API endpoint
  Future<void> _fetchQuizData() async {
    try {
      // Try the main endpoint first
      final url =
          "https://strivehigh.thirdvizion.com/api/soarcarddetails/${widget.userEmail}/?format=json&limit=10&order=desc&order_by=created_at";

      debugPrint("Attempting to fetch from: $url");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Check if response is HTML (error page) instead of JSON
        if (response.body.trim().startsWith('<!DOCTYPE') ||
            response.body.trim().startsWith('<html')) {
          debugPrint(
            "API returned HTML instead of JSON - trying fallback endpoint",
          );
          await _tryFallbackEndpoint();
          return;
        }

        final data = json.decode(response.body);
        debugPrint("API Response: $data");

        // Handle the specific JSON structure from soarcarddetails API
        if (data is Map && data.containsKey('category_wise_avgs')) {
          final categoryWiseAvgs = data['category_wise_avgs'] as List<dynamic>;
          debugPrint(
            "Found ${categoryWiseAvgs.length} categories in category_wise_avgs",
          );

          // Process category_wise_avgs array
          categoryWise = [];
          for (var item in categoryWiseAvgs) {
            final category = item['category']?.toString() ?? '';
            final avg = double.tryParse(item['avg'].toString()) ?? 0.0;

            if (category.isNotEmpty) {
              categoryWise.add({"category": category, "percentage": avg});
              debugPrint("Category: $category = $avg%");
            }
          }

          // Sort by percentage descending
          categoryWise.sort(
            (a, b) => (b["percentage"] as double).compareTo(
              a["percentage"] as double,
            ),
          );

          debugPrint(
            "Loaded ${categoryWise.length} categories with actual scores for user: ${widget.userEmail}",
          );

          // Update quizCategories for compatibility
          setState(() {
            quizCategories = categoryWise
                .map(
                  (item) => {
                    "category": item["category"],
                    "score": item["percentage"],
                  },
                )
                .toList();
          });
        } else {
          debugPrint(
            "API response doesn't contain category_wise_avgs, trying fallback",
          );
          await _tryFallbackEndpoint();
        }
      } else {
        debugPrint(
          "Failed to fetch quiz data: HTTP ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      debugPrint("Exception in _fetchQuizData: $e");

      // Use sample data when API fails
      setState(() {
        categoryWise = [
          {
            "category": "Communication & influencing (Emotional Openness )",
            "percentage": 75.0,
          },
          {"category": "Situation Awareness", "percentage": 68.0},
          {"category": "Teamwork", "percentage": 72.0},
          {
            "category": "Result Focus (Professional Development & Compliance)",
            "percentage": 65.0,
          },
          {"category": "Leadership", "percentage": 58.0},
          {"category": "Stress management", "percentage": 62.0},
          {"category": "Decision making", "percentage": 55.0},
          {"category": "Crew Relationships", "percentage": 70.0},
        ];

        quizCategories = categoryWise
            .map(
              (item) => {
                "category": item["category"],
                "score": item["percentage"],
              },
            )
            .toList();

        _error = "Using sample data - API unavailable";
      });
    }
  }

  /// Try alternative API endpoints if main endpoint fails
  Future<void> _tryFallbackEndpoint() async {
    try {
      // Try simpler endpoint without query parameters
      final fallbackUrl =
          "https://strivehigh.thirdvizion.com/api/soarcarddetails/${widget.userEmail}/";
      debugPrint("Trying fallback endpoint: $fallbackUrl");

      final response = await http.get(Uri.parse(fallbackUrl));

      if (response.statusCode == 200 &&
          !response.body.trim().startsWith('<!DOCTYPE')) {
        final data = json.decode(response.body);
        debugPrint("Fallback endpoint successful");

        // Handle the same JSON structure as main endpoint
        if (data is Map && data.containsKey('category_wise_avgs')) {
          final categoryWiseAvgs = data['category_wise_avgs'] as List<dynamic>;
          debugPrint(
            "Fallback: Found ${categoryWiseAvgs.length} categories in category_wise_avgs",
          );

          categoryWise = [];
          for (var item in categoryWiseAvgs) {
            final category = item['category']?.toString() ?? '';
            final avg = double.tryParse(item['avg'].toString()) ?? 0.0;

            if (category.isNotEmpty) {
              categoryWise.add({"category": category, "percentage": avg});
            }
          }

          // Sort by percentage descending
          categoryWise.sort(
            (a, b) => (b["percentage"] as double).compareTo(
              a["percentage"] as double,
            ),
          );

          setState(() {
            quizCategories = categoryWise
                .map(
                  (item) => {
                    "category": item["category"],
                    "score": item["percentage"],
                  },
                )
                .toList();
          });

          debugPrint("Fallback: Processed ${categoryWise.length} categories");
          return;
        }
      }

      // If fallback also fails, use sample data
      debugPrint("Fallback endpoint also failed, using sample data");
      _useSampleQuizData();
    } catch (e) {
      debugPrint("Fallback endpoint failed: $e");
      _useSampleQuizData();
    }
  }

  /// Process quiz data and update UI
  void _processQuizData(List<dynamic> results) {
    final Map<String, List<double>> categoryScores = {};

    for (var item in results) {
      final category = item['category']?.toString() ?? '';
      final score = double.tryParse(item['score'].toString()) ?? 0.0;

      if (category.isNotEmpty) {
        if (!categoryScores.containsKey(category)) {
          categoryScores[category] = [];
        }
        categoryScores[category]!.add(score);
      }
    }

    // Calculate average scores for each category
    categoryWise = [];
    categoryScores.forEach((category, scores) {
      final averageScore = scores.reduce((a, b) => a + b) / scores.length;
      categoryWise.add({"category": category, "percentage": averageScore});
    });

    // Sort by percentage descending
    categoryWise.sort(
      (a, b) =>
          (b["percentage"] as double).compareTo(a["percentage"] as double),
    );

    setState(() {
      quizCategories = categoryWise
          .map(
            (item) => {
              "category": item["category"],
              "score": item["percentage"],
            },
          )
          .toList();
    });

    debugPrint("Processed ${categoryWise.length} categories from API data");
  }

  /// Use sample data when API fails
  void _useSampleQuizData() {
    setState(() {
      categoryWise = [
        {
          "category": "Communication & influencing (Emotional Openness )",
          "percentage": 75.0,
        },
        {"category": "Situation Awareness", "percentage": 68.0},
        {"category": "Teamwork", "percentage": 72.0},
        {
          "category": "Result Focus (Professional Development & Compliance)",
          "percentage": 65.0,
        },
        {"category": "Leadership", "percentage": 58.0},
        {"category": "Stress management", "percentage": 62.0},
        {"category": "Decision making", "percentage": 55.0},
        {"category": "Crew Relationships", "percentage": 70.0},
      ];

      quizCategories = categoryWise
          .map(
            (item) => {
              "category": item["category"],
              "score": item["percentage"],
            },
          )
          .toList();

      _error = "Using sample data - API unavailable";
    });
  }

  Future<void> _fetchSoarCardDetails() async {
    try {
      if (widget.userEmail.isEmpty) {
        throw Exception("User email is empty");
      }

      final url =
          "https://strivehigh.thirdvizion.com/api/usersdetails/${Uri.encodeComponent(widget.userEmail)}";

      debugPrint("Fetching data from API endpoint: $url");

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw Exception("Request timeout - server may be unreachable"),
          );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // ✅ Response is a List, so pick the first element
        if (decoded is List && decoded.isNotEmpty) {
          final data = decoded.first;

          debugPrint("Successfully connected to: $url");
          debugPrint("Available keys: ${data.keys}");

          setState(() {
            _userName =
                data['sailor_name']?.toString() ??
                data['name']?.toString() ??
                data['username']?.toString() ??
                '';
            _userEmail = data['user_email']?.toString() ?? widget.userEmail;

            // ✅ Use avg array (since categoryWise is not returned)
            if (data['avg'] != null) {
              List<dynamic> avgList = data['avg'] as List<dynamic>;
              categoryWise = [];
              for (
                int i = 0;
                i < avgList.length && i < predefinedCategories.length;
                i++
              ) {
                final percentage =
                    double.tryParse(avgList[i].toString()) ?? 0.0;
                categoryWise.add({
                  "category": predefinedCategories[i],
                  "percentage": percentage,
                });
                debugPrint(
                  "Category ${i + 1}: ${predefinedCategories[i]} = $percentage%",
                );
              }
              debugPrint(
                "Loaded ${categoryWise.length} categories from avg array",
              );
            } else {
              debugPrint("No 'avg' data found in API response");
              categoryWise = [];
            }

            _isLoading = false;
          });

          // Save sailor_name to SharedPreferences if available
          if (_userName?.isNotEmpty == true) {
            await UserProfileService.saveUserProfile(name: _userName!);
          }

          // Fetch quiz data which will update categoryWise with real assessment scores
          await _fetchQuizData();
        } else {
          throw Exception("API returned empty list");
        }
      } else {
        debugPrint("HTTP error ${response.statusCode}: ${response.body}");
        _useSampleData();
      }
    } catch (e) {
      debugPrint("Exception in _fetchSoarCardDetails: $e");
      await _useSharedPreferencesData();
    }
  }

  Future<void> _useSharedPreferencesData() async {
    try {
      final userNameFromPrefs = await UserProfileService.getUserName();
      setState(() {
        _userName = (userNameFromPrefs.isNotEmpty)
            ? userNameFromPrefs
            : 'Sample User';
        _userEmail = widget.userEmail;
        categoryWise = [
          {
            "category": "Communication & influencing (Emotional Openness )",
            "percentage": 80.0,
          },
          {"category": "Situation Awareness", "percentage": 75.0},
          {"category": "Teamwork", "percentage": 70.0},
          {
            "category": "Result Focus (Professional Development & Compliance)",
            "percentage": 65.0,
          },
          {"category": "Leadership", "percentage": 60.0},
          {"category": "Stress management", "percentage": 55.0},
          {"category": "Decision making", "percentage": 50.0},
          {"category": "Crew Relationships", "percentage": 45.0},
          {"category": "Help-Seeking", "percentage": 40.0},
          {"category": "Empathy", "percentage": 35.0},
          {"category": "Command Pressure", "percentage": 30.0},
        ];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching user name from SharedPreferences: $e");
      _useSampleData();
    }
  }

  void _useSampleData() {
    setState(() {
      _userName = 'Sample User';
      _userEmail = widget.userEmail;
      categoryWise = [
        {
          "category": "Communication & influencing (Emotional Openness )",
          "percentage": 80.0,
        },
        {"category": "Situation Awareness", "percentage": 75.0},
        {"category": "Teamwork", "percentage": 70.0},
        {
          "category": "Result Focus (Professional Development & Compliance)",
          "percentage": 65.0,
        },
        {"category": "Leadership", "percentage": 60.0},
        {"category": "Stress management", "percentage": 55.0},
        {"category": "Decision making", "percentage": 50.0},
        {"category": "Crew Relationships", "percentage": 45.0},
        {"category": "Help-Seeking", "percentage": 40.0},
        {"category": "Empathy", "percentage": 35.0},
        {"category": "Command Pressure", "percentage": 30.0},
      ];
      _isLoading = false;
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.blue,
        image: DecorationImage(
          image: AssetImage('lib/assets/images/world.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),

      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            "KNOW",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            _userName != null && _userName!.isNotEmpty
                ? "$_userName's SOAR CARD"
                : "SOAR CARD",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2),
          Text(
            "Result",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Strength, Opportunities, Aspirations & Recommendations",
            style: TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Modern SOAR Assessment Overview
  Widget _buildSoarCard() {
    if (categoryWise.isEmpty) {
      return _buildEmptyState();
    }

    // Use category-wise percentages
    final maxValue = categoryWise
        .map((e) => e["percentage"] as double)
        .reduce((a, b) => a > b ? a : b);
    final avgScore =
        categoryWise
            .map((e) => e["percentage"] as double)
            .reduce((a, b) => a + b) /
        categoryWise.length;

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with insights
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your SOAR Assessment",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _error != null
                            ? "Sample data (API unavailable) • ${_getOverallInsight(avgScore)}"
                            : _getOverallInsight(avgScore),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Score summary
            _buildScoreSummary(avgScore, maxValue),
            // Category pie chart
            _buildCategoryPieChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Assessment Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your SOAR assessment to see your results here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummary(double avgScore, double maxValue) {
    final percentage = avgScore.round();
    final level = _getPerformanceLevel(percentage);

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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: level['colors'] as List<Color>),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  level['description'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    if (categoryWise.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Category Performance Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No assessment data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete the SOAR assessment to see your results',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Sort categories by percentage descending
    List<Map<String, dynamic>> sortedCategories = List.from(categoryWise);
    sortedCategories.sort(
      (a, b) =>
          (b["percentage"] as double).compareTo(a["percentage"] as double),
    );

    // Use actual percentages from the data, but ensure they're reasonable for visualization
    final sections = <PieChartSectionData>[];
    debugPrint("Building pie chart with ${sortedCategories.length} categories");

    for (int i = 0; i < sortedCategories.length; i++) {
      final item = sortedCategories[i];
      final actualPercentage = item["percentage"] as double;

      // Ensure percentage is between 0 and 100 for proper visualization
      final displayPercentage = actualPercentage.clamp(0.0, 100.0);
      final color = _getPieColorByIndex(i, sortedCategories.length);

      debugPrint(
        "Pie chart section ${i + 1}: ${item["category"]} = $displayPercentage%",
      );

      // For equal scores, distribute evenly across the pie chart
      final equalValue = 100.0 / sortedCategories.length;

      sections.add(
        PieChartSectionData(
          color: color,
          value: equalValue,
          radius: 56,
          borderSide: BorderSide.none,
          title: '', // Hide percentage text in pie chart sections
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Category Performance Distribution',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: 230,
            width: 350,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 70,
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      'SOAR Analysis',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: sortedCategories.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final category = item["category"] as String;
              final percentage = item["percentage"] as double;
              final color = _getPieColorByIndex(i, sortedCategories.length);

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),

                  Text(
                    category,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getOverallInsight(double avgScore) {
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

  Map<String, dynamic> _getPerformanceLevel(int percentage) {
    if (percentage >= 80) {
      return {
        'title': 'Excellent',
        'description': 'Outstanding performance across all competencies',
        'colors': [Colors.green.shade500, Colors.green.shade600],
      };
    } else if (percentage >= 60) {
      return {
        'title': 'Good',
        'description': 'Strong foundation with areas for growth',
        'colors': [Colors.blue.shade500, Colors.blue.shade600],
      };
    } else if (percentage >= 40) {
      return {
        'title': 'Developing',
        'description': 'Good progress with focused improvement needed',
        'colors': [Colors.orange.shade500, Colors.orange.shade600],
      };
    } else {
      return {
        'title': 'Beginning',
        'description': 'Starting your development journey',
        'colors': [Colors.red.shade500, Colors.red.shade600],
      };
    }
  }

  Color _getPieColor(int percentage) {
    if (percentage >= 90) return const Color.fromRGBO(247, 204, 28, 1.0);
    if (percentage >= 80) return const Color.fromRGBO(4, 105, 225, 1.0);
    if (percentage >= 70) return const Color.fromRGBO(42, 141, 236, 1.0);
    if (percentage >= 60) return const Color.fromRGBO(255, 142, 28, 1.0);
    if (percentage >= 50) return const Color.fromRGBO(19, 214, 214, 1.0);
    if (percentage >= 40) return const Color.fromRGBO(87, 211, 92, 1.0);
    if (percentage >= 30) return const Color.fromRGBO(247, 84, 63, 1.0);
    if (percentage >= 20) return Colors.deepOrange.shade600;
    if (percentage >= 10) return Colors.red.shade600;
    return Colors.red.shade900;
  }

  /// Get distinct colors for pie chart sections based on index
  Color _getPieColorByIndex(int index, int totalCategories) {
    // Define a palette of distinct colors
    final List<Color> colorPalette = [
      const Color.fromRGBO(4, 105, 225, 1.0), // Blue
      const Color.fromRGBO(247, 204, 28, 1.0), // Yellow
      const Color.fromRGBO(19, 214, 214, 1.0), // Cyan
      const Color.fromRGBO(87, 211, 92, 1.0), // Green
      const Color.fromRGBO(255, 142, 28, 1.0), // Orange
      const Color.fromRGBO(247, 84, 63, 1.0), // Red
      const Color.fromRGBO(156, 39, 176, 1.0), // Purple
      const Color.fromRGBO(42, 141, 236, 1.0), // Light Blue
      const Color.fromRGBO(76, 175, 80, 1.0), // Light Green
      const Color.fromRGBO(255, 193, 7, 1.0), // Amber
      const Color.fromRGBO(233, 30, 99, 1.0), // Pink
      const Color.fromRGBO(96, 125, 139, 1.0), // Blue Grey
    ];

    // Use modulo to cycle through colors if there are more categories than colors
    return colorPalette[index % colorPalette.length];
  }

  /// Expandable SOAR Cards matching the image design
  Widget _buildCompetencyCard() {
    if (categoryWise.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: categoryWise.map((item) {
          return _buildExpandableSoarCard(item);
        }).toList(),
      ),
    );
  }

  Widget _buildExpandableSoarCard(Map<String, dynamic> item) {
    final category = item["category"] as String;
    final score = item["percentage"] as double;

    // Use the actual score as percentage
    final percentage = score.round();

    final isExpanded = _expandedCategories[category] ?? false;

    // Get score range and original feedback
    final scoreRange = _getScoreRange(percentage);
    final originalFeedback = scoreRanges[scoreRange] ?? scoreRanges["0-9"]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main card content
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedCategories[category] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category name
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress bar and percentage
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getProgressBarColor(percentage),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "$percentage%",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Dynamic feedback text with info icon
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _getProgressBarColor(percentage),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getFeedbackText(percentage),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(
                            0xFF2D3748,
                          ), // Darker color for better readability
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (isExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildAIResponse(category, percentage, originalFeedback),
              ),
            ),
        ],
      ),
    );
  }

  String _getScoreRange(int percentage) {
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

  Color _getProgressBarColor(int percentage) {
    // Use blue gradient colors for all progress bars
    if (percentage >= 80) return const Color(0xFF79FEFC);
    if (percentage >= 60) return const Color(0xFF239CD3);
    if (percentage >= 40) return const Color(0xFF239CD3).withOpacity(0.8);
    if (percentage >= 20) return const Color(0xFF239CD3).withOpacity(0.6);
    return const Color(0xFF239CD3).withOpacity(0.4);
  }

  String _getFeedbackText(int percentage) {
    if (percentage >= 80) return "Excellent performance!";
    if (percentage >= 60) return "Good progress, keep it up!";
    if (percentage >= 40) return "Focus on improving";
    if (percentage >= 20) return "Needs attention";
    return "Requires development";
  }

  Widget _buildAIResponse(
    String category,
    int percentage,
    Map<String, String> originalFeedback,
  ) {
    final cacheKey = '${category}_$percentage';

    // Check if we have a cached response
    if (_aiResponseCache.containsKey(cacheKey)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            originalFeedback["title"]!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _aiResponseCache[cacheKey]!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3748),
              height: 1.4,
            ),
          ),
        ],
      );
    }

    // Generate new AI response if not cached
    return FutureBuilder<String>(
      future: OpenRouterAPI.getSOARFeedback(
        category: category,
        score: percentage,
        originalFeedback: originalFeedback["feedback"]!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text(
                "Generating personalized feedback...",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          );
        }

        final emotionalFeedback =
            snapshot.data ?? originalFeedback["feedback"]!;

        // Cache the response
        _aiResponseCache[cacheKey] = emotionalFeedback;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              originalFeedback["title"]!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emotionalFeedback,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                height: 1.4,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPdfDownloadButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: categoryWise.isEmpty
                  ? null
                  : () async {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          content: Row(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(width: 16),
                              const Text('Generating PDF...'),
                            ],
                          ),
                        ),
                      );

                      try {
                        await SoarPdfGenerator.generateAndDownloadPdf(
                          userEmail: widget.userEmail,
                          userName: _userName ?? '',
                          categoryWise: categoryWise,
                          overallAvg: overallAvg,
                          context: context,
                        );
                      } finally {
                        // Close loading dialog
                        Navigator.of(context).pop();
                      }
                    },
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text('Download PDF Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Optional: Add a preview button
          ElevatedButton(
            onPressed: categoryWise.isEmpty
                ? null
                : () {
                    _showPdfPreviewDialog();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Icon(Icons.preview_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  void _showPdfPreviewDialog() {
    final avgScore = categoryWise.isNotEmpty
        ? categoryWise
                  .map((e) => e["percentage"] as double)
                  .reduce((a, b) => a + b) /
              categoryWise.length
        : 0.0;
    final percentage = avgScore.round();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Report Preview'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User: ${widget.userEmail}'),
              const SizedBox(height: 8),
              Text('Overall Score: $percentage%'),
              const SizedBox(height: 8),
              Text('Categories: ${categoryWise.length}'),
              const SizedBox(height: 16),
              const Text('This PDF will include:'),
              const SizedBox(height: 8),
              const Text('• Complete assessment overview'),
              const Text('• Category-wise performance breakdown'),
              const Text('• Detailed feedback for each category'),
              const Text('• Professional formatting and branding'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  content: Row(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 16),
                      const Text('Generating PDF...'),
                    ],
                  ),
                ),
              );

              try {
                await SoarPdfGenerator.generateAndDownloadPdf(
                  userEmail: widget.userEmail,
                  userName: _userName ?? '',
                  categoryWise: categoryWise,
                  overallAvg: overallAvg,
                  context: context,
                );
              } finally {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Generate PDF'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _error != null
                ? _buildErrorState()
                : RefreshIndicator(
                    onRefresh: refreshSoarData,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 20),
                      children: [
                        _buildSoarCard(),
                        _buildCompetencyCard(),
                        // Add the PDF download button here
                        _buildPdfDownloadButton(),
                      ],
                    ),
                  ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade500),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Analyzing your assessment...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchSoarCardDetails();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GoalInfoScreen(userEmail: widget.userEmail),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Continue to Goal Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
