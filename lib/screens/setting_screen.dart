import 'package:flutter/material.dart';
import 'notification_settings_screen.dart';
import 'mood_analytics_screen.dart';
import 'ai_knowledge_base_screen.dart';
import 'avatar_selection_screen.dart';
import '../services/auth_service.dart';
import '../providers/locale_provider.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  List<Map<String, dynamic>> getSettings(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      {
        "id": "analytics",
        "icon": Icons.insert_chart,
        "label": localizations.analytics,
        "color": Colors.deepPurpleAccent,
      },
      {
        "id": "theme",
        "icon": Icons.color_lens,
        "label": localizations.theme,
        "color": Colors.teal,
        "isToggle": true,
      },
      {
        "id": "wallpaper",
        "icon": Icons.wallpaper,
        "label": localizations.wallpaper,
        "color": Colors.lightBlue,
      },
      {
        "id": "aiKnowledgeBase",
        "icon": Icons.psychology,
        "label": localizations.aiKnowledgeBase,
        "color": Colors.deepOrange,
      },
      {
        "id": "notification",
        "icon": Icons.notifications,
        "label": localizations.notification,
        "color": Colors.orange,
      },
      {
        "id": "language",
        "icon": Icons.language,
        "label": localizations.language,
        "color": Colors.purple,
      },
      {
        "id": "changeAvatar",
        "icon": Icons.person,
        "label": localizations.changeAvatar,
        "color": Colors.blue,
      },
      {
        "id": "helpCenter",
        "icon": Icons.help_center,
        "label": localizations.helpCenter,
        "color": Colors.green,
      },
      {
        "id": "termsPrivacy",
        "icon": Icons.privacy_tip,
        "label": localizations.termsPrivacy,
        "color": Colors.lightBlue,
      },
      {
        "id": "appVersion",
        "icon": Icons.phone_iphone,
        "label": localizations.appVersion,
        "color": Colors.teal,
      },
      {
        "id": "logout",
        "icon": Icons.logout,
        "label": localizations.logout,
        "color": Colors.red,
      },
    ];
  }

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
    // You can add additional logic here to persist the theme preference or notify other parts of the app
  }

  Future<void> _handleSettingTap(BuildContext context, String id) async {
    switch (id) {
      case 'analytics':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MoodAnalyticsScreen(),
          ),
        );
        break;
      case 'aiKnowledgeBase':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AIKnowledgeBaseScreen(),
          ),
        );
        break;
      case 'notification':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationSettingsScreen(),
          ),
        );
        break;
      case 'language':
        _showLanguageDialog(context);
        break;
      case 'changeAvatar':
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AvatarSelectionScreen(
              isChangingAvatar: true,
            ),
          ),
        );
        
        // If avatar was changed successfully, refresh the grow screen
        if (result == true) {
          // Trigger a rebuild of the grow screen to reflect avatar changes
          // This will be handled by the grow screen's lifecycle
        }
        break;
      case 'helpCenter':
        _showHelpDialog(context);
        break;
      case 'termsPrivacy':
        _showPrivacyDialog(context);
        break;
      case 'appVersion':
        _showVersionDialog(context);
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
      default:
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.featureComingSoon(id)),
            backgroundColor: Colors.blue,
          ),
        );
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String selectedLanguage = localeProvider.locale.languageCode;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(localizations.selectLanguageTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: Text(localizations.english),
                      value: "en",
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text(localizations.spanish),
                      value: "es",
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text("French"),
                      value: "fr",
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text("Tamil"),
                      value: "ta",
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text("Japanese"),
                      value: "ja",
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text("Chinese"),
                      value: "zh",
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(localizations.cancel),
                ),
                TextButton(
                  onPressed: () {
                    localeProvider.setLocale(Locale(selectedLanguage));
                    Navigator.of(dialogContext).pop();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.languageChanged),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: Text(localizations.ok),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.helpCenterTitle),
        content: Text(localizations.helpCenterContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.ok),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.privacyPolicyTitle),
        content: SingleChildScrollView(
          child: Text(localizations.privacyPolicyContent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.ok),
          ),
        ],
      ),
    );
  }

  void _showVersionDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.appVersionTitle),
        content: Text(localizations.appVersionContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.ok),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.logoutTitle),
        content: Text(localizations.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Logout user
              await AuthService.logout();

              if (context.mounted) {
                // Navigate to login screen and clear all previous routes
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations.logout),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final localizations = AppLocalizations.of(context)!;
        final settings = getSettings(context);

        return Scaffold(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                /// Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Removed CircleAvatar with eye icon
                      // Removed CircleAvatar with profile image
                    ],
                  ),
                ),

                /// Settings Title
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, top: 8.0, bottom: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localizations.settings,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),

                /// Settings List
                Expanded(
                  child: ListView.builder(
                    itemCount: settings.length,
                    itemBuilder: (context, index) {
                      final item = settings[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item['color'].withOpacity(0.2),
                          child: Icon(item['icon'], color: item['color']),
                        ),
                        title: Text(
                          item['label'],
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        trailing: item['isToggle'] == true
                            ? Switch(
                                value: isDarkMode,
                                onChanged: toggleTheme,
                              )
                            : null,
                        onTap: () {
                          _handleSettingTap(context, item['id']);
                        },
                      );
                    },
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
