import 'package:SeaSmart/screens/certificate_screen.dart'
    show CertificateScreen;
import 'package:SeaSmart/screens/feedback_screen.dart';
import 'package:SeaSmart/screens/mood_analytics_screen.dart'
    show MoodAnalyticsScreen;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'l10n/app_localizations.dart';
import 'screens/avatar_selection_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/grow_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/daily_checkin_screen.dart';
import 'screens/login_screen.dart';
import 'providers/journal_entries_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/tutorial_onboarding_screen.dart';
import 'screens/tutorial_demo_screen.dart';
import 'services/backend_pdf_service.dart';
import 'services/notification_service.dart';
import 'services/user_profile_service.dart';
import 'services/auth_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone for notifications
  tz.initializeTimeZones();

  // Initialize services
  await BackendPDFService.loadPDFFromAssets();
  await NotificationService.initialize();

  // Enable notifications by default (compulsory)
  await NotificationService.enableDefaultNotifications();

  //await dotenv.load(fileName: ".env");

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JournalEntriesProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return ShowCaseWidget(
            builder: (context) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'SeaSmart - AI Mental Health Assistant',
              theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.deepPurple,
                brightness: Brightness.light,
              ),
              locale: localeProvider.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const SplashScreen(),
              routes: {
                '/login': (context) => const LoginScreen(),
                '/onboarding': (context) => OnboardingScreen(userEmail: ''),
                '/avatar-selection': (context) => const AvatarSelectionScreen(),
                '/daily-checkin': (context) => const DailyCheckinScreen(),
                '/dashboard': (context) => const DashboardScreen(),
                '/home': (context) => const GrowScreen(),
                '/chat': (context) => const ChatScreen(),
                '/journal': (context) => const JournalScreen(),
                '/mood-analytics': (context) => const MoodAnalyticsScreen(),
                '/certificates': (context) => const CertificateScreen(),
                '/report': (context) => const FeedbackScreen(),
                '/tutorial': (context) =>
                    TutorialOnboardingScreen(userEmail: ''),
                '/tutorial-demo': (context) => const TutorialDemoScreen(),
              },
            ),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    // Wait for splash screen duration
    await Future.delayed(const Duration(milliseconds: 3000));

    if (!mounted) return;

    try {
      print('🔍 Checking authentication status...');

      // Check if user is logged in
      final isLoggedIn = await AuthService.isLoggedIn();
      print('🔐 User logged in: $isLoggedIn');

      if (!mounted) return;

      if (!isLoggedIn) {
        // User not logged in - go to login screen
        print('📱 Navigating to login screen');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // User is logged in - check if this is their first time
      final isFirstTime = await UserProfileService.isFirstTime();
      print('👤 First time user: $isFirstTime');

      if (!mounted) return;

      if (isFirstTime) {
        // First time user - go to onboarding
        final userEmail =
            await AuthService.getToken(); // Get user email from auth
        print('📱 Navigating to onboarding screen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(userEmail: userEmail ?? ''),
          ),
        );
      } else {
        // Returning user - check if they have set goals
        final hasSetGoals = await UserProfileService.hasSetGoals();
        print('🎯 User has set goals: $hasSetGoals');

        if (!mounted) return;

        if (!hasSetGoals) {
          // User hasn't set goals yet - go to goal setting (onboarding)
          final userEmail = await AuthService.getToken();
          print(
            '🎯 User needs to set goals first - Navigating to goal setting',
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OnboardingScreen(userEmail: userEmail ?? ''),
            ),
          );
        } else {
          // User has set goals - now check for daily mood analysis
          final needsDailyCheckin =
              await UserProfileService.needsDailyCheckin();
          print(
            '🎯 Goals are set - Checking daily mood analysis: $needsDailyCheckin',
          );

          if (!mounted) return;

          if (needsDailyCheckin) {
            // User needs to do daily mood analysis
            print('📊 Daily mood analysis required - Navigating to check-in');
            Navigator.pushReplacementNamed(context, '/daily-checkin');
          } else {
            // User already completed today's mood analysis - go to home
            print('✅ Daily mood analysis completed - Navigating to home');
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    } catch (e) {
      // If any error occurs, go to login screen
      print('❌ Error during navigation: $e');
      if (mounted) {
        print('📱 Navigating to login screen (error fallback)');
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'lib/assets/videos/splash1.gif',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if GIF doesn't exist or fails to load
            print('❌ GIF loading error: $error');
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/icons/app_icon.png',
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SeaSmart',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your Mental Wellness Companion',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
