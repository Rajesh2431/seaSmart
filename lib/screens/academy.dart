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

    final List<Map<String, String>> striveCourses = [
      {
        "title": localizations.courseWellness,
        "image": "lib/assets/images/lonely.png",
        "url":
            "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/",
      },
      {
        "title": localizations.courseStressManagement,
        "image": "lib/assets/images/stress.png",
        "url":
            "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/",
      },
      {
        "title": localizations.courseLoneliness,
        "image": "lib/assets/images/loneliness.png",
        "url":
            "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/",
      },
    ];

    final List<Map<String, String>> professionalSkills = [
      {
        "title": localizations.courseManagement,
        "image": "lib/assets/images/management.png",
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
        "image": "lib/assets/images/dec.png",
        "url":
            "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text(
          localizations.striveHigh,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
              margin: const EdgeInsets.all(12.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF21A2D0), // Dark grey background
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mandatory Courses for Seafarers",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        final courses = [
                          {
                            'title': 'Mental Health',
                            'image': 'lib/assets/icons/Mental_health.png',
                          },
                          {
                            'title': 'Harassment & Bullying',
                            'image': 'lib/assets/icons/Bullying.png',
                          },
                        ];
                        return _MandatoryCourseCard(
                          title: courses[index]['title']!,
                          image: courses[index]['image']!,
                          onTap: () => _navigateToMandatoryCourse(context, courses[index]['title']!),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                localizations.striveHighCourses,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Horizontal scroll - StriveHigh Courses
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: striveCourses.length,
                itemBuilder: (context, index) {
                  return CourseCard(
                    title: striveCourses[index]['title']!,
                    image: striveCourses[index]['image']!,
                    url: striveCourses[index]['url']!,
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                localizations.professionalSkills,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Horizontal scroll - Professional Skills
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: professionalSkills.length,
                itemBuilder: (context, index) {
                  return CourseCard(
                    title: professionalSkills[index]['title']!,
                    image: professionalSkills[index]['image']!,
                    url: professionalSkills[index]['url']!,
                  );
                },
              ),
            ),
            const SizedBox(height: 150),
            // Bottom Banner
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    localizations.yourCalmCompass,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.chatWithAnExpert,
                    style: const TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          launchUrl(
                            Uri.parse("tel:+911234567890"),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: const Icon(Icons.call, color: Colors.white),
                        label: Text(
                          localizations.call,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          launchUrl(
                            Uri.parse("https://example.com/chat"),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: Text(
                          localizations.chat,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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

  const CourseCard({
    super.key,
    required this.title,
    required this.image,
    required this.url,
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// Navigation method for mandatory courses
void _navigateToMandatoryCourse(BuildContext context, String courseTitle) async {
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
      builder: (context) => InnerCourse(courseTitle: courseTitle, userEmail: userEmail),
    ),
  );
}

// Mandatory Course Card Widget
class _MandatoryCourseCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const _MandatoryCourseCard({
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
          image: DecorationImage(
            image: AssetImage(image), 
            fit: BoxFit.cover
          ),
        ),
      ),
    );
  }
}
