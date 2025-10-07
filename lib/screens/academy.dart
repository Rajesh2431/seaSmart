import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'innercourse.dart';
import '../services/user_profile_service.dart';
import '../l10n/app_localizations.dart';

class Academy extends StatelessWidget {
  const Academy({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive card width
    final cardWidth = screenWidth > 600 ? 240.0 : 200.0;
    final imageHeight = screenWidth > 600 ? 140.0 : 110.0;

    final List<Map<String, String>> striveCourses = [
      {
        "title": localizations.courseWellness,
        "image": "lib/assets/images/anger.png",
        "url":
            "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/",
      },
      {
        "title": localizations.courseStressManagement,
        "image": "lib/assets/images/stressManagement.png",
        "url":
            "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/",
      },
      {
        "title": localizations.courseLoneliness,
        "image": "lib/assets/images/loneliess.png",
        "url":
            "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/",
      },
    ];

    final List<Map<String, String>> professionalSkills = [
      {
        "title": localizations.courseManagement,
        "image": "lib/assets/images/teamManagement.png",
        "url":
            "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/",
      },
      {
        "title": localizations.courseLeadership,
        "image": "lib/assets/images/leadership.png",
        "url":
            "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/",
      },
      {
        "title": localizations.courseDecisionMaking,
        "image": "lib/assets/images/decisionMaking.png",
        "url":
            "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          localizations.striveHigh,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      drawer: const Drawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mandatory Courses Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF21A2D0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Mandatory Courses for Seafarers",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: imageHeight + 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        final courses = [
                          {
                            'title': 'Mental Health',
                            'image': 'lib/assets/images/mentalHealth.png',
                          },
                          {
                            'title': 'Harassment & Bullying',
                            'image': 'lib/assets/images/bullying.png',
                          },
                        ];
                        return _MandatoryCourseCard(
                          title: courses[index]['title']!,
                          image: courses[index]['image']!,
                          cardWidth: cardWidth,
                          imageHeight: imageHeight,
                          onTap: () => _navigateToMandatoryCourse(
                            context,
                            courses[index]['title']!,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations.striveHighCourses,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // Horizontal scroll - StriveHigh Courses
            SizedBox(
              height: imageHeight + 80,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                itemCount: striveCourses.length,
                itemBuilder: (context, index) {
                  return CourseCard(
                    title: striveCourses[index]['title']!,
                    image: striveCourses[index]['image']!,
                    url: striveCourses[index]['url']!,
                    cardWidth: cardWidth,
                    imageHeight: imageHeight,
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations.professionalSkills,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // Horizontal scroll - Professional Skills
            SizedBox(
              height: imageHeight + 80,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                itemCount: professionalSkills.length,
                itemBuilder: (context, index) {
                  return CourseCard(
                    title: professionalSkills[index]['title']!,
                    image: professionalSkills[index]['image']!,
                    url: professionalSkills[index]['url']!,
                    cardWidth: cardWidth,
                    imageHeight: imageHeight,
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // Bottom Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100, width: 2),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.support_agent,
                      color: Colors.blue.shade700,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.yourCalmCompass,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.chatWithAnExpert,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  screenWidth > 400
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    launchUrl(
                                      Uri.parse("tel:+911234567890"),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.call,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    localizations.call,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    launchUrl(
                                      Uri.parse("https://example.com/chat"),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.chat,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    localizations.chat,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  launchUrl(
                                    Uri.parse("tel:+911234567890"),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                icon: const Icon(
                                  Icons.call,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  localizations.call,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  launchUrl(
                                    Uri.parse("https://example.com/chat"),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                icon: const Icon(
                                  Icons.chat,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  localizations.chat,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String title;
  final String image;
  final String url;
  final double cardWidth;
  final double imageHeight;

  const CourseCard({
    super.key,
    required this.title,
    required this.image,
    required this.url,
    required this.cardWidth,
    required this.imageHeight,
  });

  void _navigateToCourse(BuildContext context) async {
    // Get user email from UserProfileService
    final userEmail = await UserProfileService.getUserEmail();

    // Debug: Print the user email being passed
    print('DEBUG: Academy - User email from UserProfileService: "$userEmail"');
    print('DEBUG: Academy - Course title: $title');

    // Check if email is empty and show error if needed
    if (userEmail.isEmpty) {
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.pleaseLoginFirst),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to inner course page with the course title and user email
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            InnerCourse(courseTitle: title, userEmail: userEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToCourse(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                image,
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Start Course',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Navigation method for mandatory courses
void _navigateToMandatoryCourse(
  BuildContext context,
  String courseTitle,
) async {
  // Get user email from UserProfileService
  final userEmail = await UserProfileService.getUserEmail();

  // Debug: Print the user email being passed
  print('DEBUG: Academy - User email from UserProfileService: "$userEmail"');
  print('DEBUG: Academy - Mandatory course title: $courseTitle');

  // Check if email is empty and show error if needed
  if (userEmail.isEmpty) {
    final localizations = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.pleaseLoginFirst),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Navigate to inner course page with the course title and user email
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          InnerCourse(courseTitle: courseTitle, userEmail: userEmail),
    ),
  );
}

// Mandatory Course Card Widget
class _MandatoryCourseCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;
  final double cardWidth;
  final double imageHeight;

  const _MandatoryCourseCard({
    required this.title,
    required this.image,
    required this.onTap,
    required this.cardWidth,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                image,
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'MANDATORY',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
