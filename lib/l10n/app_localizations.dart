import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ta'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SeaSmart - AI Mental Health Assistant'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @wallpaper.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper'**
  String get wallpaper;

  /// No description provided for @aiKnowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'AI Knowledge Base'**
  String get aiKnowledgeBase;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @termsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy Policy'**
  String get termsPrivacy;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @striveHigh.
  ///
  /// In en, this message translates to:
  /// **'StriveHigh'**
  String get striveHigh;

  /// No description provided for @striveHighCourses.
  ///
  /// In en, this message translates to:
  /// **'StriveHigh Courses'**
  String get striveHighCourses;

  /// No description provided for @professionalSkills.
  ///
  /// In en, this message translates to:
  /// **'Professional Skills'**
  String get professionalSkills;

  /// No description provided for @yourCalmCompass.
  ///
  /// In en, this message translates to:
  /// **'Your calm compass, day and night'**
  String get yourCalmCompass;

  /// No description provided for @chatWithAnExpert.
  ///
  /// In en, this message translates to:
  /// **'Chat with an expert whenever you need. We\'re here for you, 24/7'**
  String get chatWithAnExpert;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @pleaseLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'Please log in first to access courses'**
  String get pleaseLoginFirst;

  /// No description provided for @courseWellness.
  ///
  /// In en, this message translates to:
  /// **'Wellness'**
  String get courseWellness;

  /// No description provided for @courseStressManagement.
  ///
  /// In en, this message translates to:
  /// **'Stress Management'**
  String get courseStressManagement;

  /// No description provided for @courseLoneliness.
  ///
  /// In en, this message translates to:
  /// **'Loneliness'**
  String get courseLoneliness;

  /// No description provided for @courseManagement.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get courseManagement;

  /// No description provided for @courseLeadership.
  ///
  /// In en, this message translates to:
  /// **'Leadership'**
  String get courseLeadership;

  /// No description provided for @courseDecisionMaking.
  ///
  /// In en, this message translates to:
  /// **'Decision Making'**
  String get courseDecisionMaking;

  /// No description provided for @leftNostrilIn.
  ///
  /// In en, this message translates to:
  /// **'Left nostril in'**
  String get leftNostrilIn;

  /// No description provided for @hold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get hold;

  /// No description provided for @rightNostrilOut.
  ///
  /// In en, this message translates to:
  /// **'Right nostril out'**
  String get rightNostrilOut;

  /// No description provided for @rightNostrilIn.
  ///
  /// In en, this message translates to:
  /// **'Right nostril in'**
  String get rightNostrilIn;

  /// No description provided for @leftNostrilOut.
  ///
  /// In en, this message translates to:
  /// **'Left nostril out'**
  String get leftNostrilOut;

  /// No description provided for @sessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session Complete'**
  String get sessionComplete;

  /// No description provided for @quote1.
  ///
  /// In en, this message translates to:
  /// **'Ancient yogic technique for perfect balance 🌬️'**
  String get quote1;

  /// No description provided for @quote2.
  ///
  /// In en, this message translates to:
  /// **'Harmonize your left and right brain ✨'**
  String get quote2;

  /// No description provided for @quote3.
  ///
  /// In en, this message translates to:
  /// **'Alternate breathing, alternate awareness 🧘‍♀️'**
  String get quote3;

  /// No description provided for @quote4.
  ///
  /// In en, this message translates to:
  /// **'Balance your nervous system naturally 💫'**
  String get quote4;

  /// No description provided for @quote5.
  ///
  /// In en, this message translates to:
  /// **'Pranayama brings inner peace 🕊️'**
  String get quote5;

  /// No description provided for @alternateNostrilBreathing.
  ///
  /// In en, this message translates to:
  /// **'Alternate Nostril Breathing'**
  String get alternateNostrilBreathing;

  /// No description provided for @ancientYogicTechnique.
  ///
  /// In en, this message translates to:
  /// **'Ancient yogic technique to balance mind and body'**
  String get ancientYogicTechnique;

  /// No description provided for @chooseSessionDuration.
  ///
  /// In en, this message translates to:
  /// **'Choose your session duration'**
  String get chooseSessionDuration;

  /// No description provided for @oneMinute.
  ///
  /// In en, this message translates to:
  /// **'1 Minute'**
  String get oneMinute;

  /// No description provided for @threeMinutes.
  ///
  /// In en, this message translates to:
  /// **'3 Minutes'**
  String get threeMinutes;

  /// No description provided for @fiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 Minutes'**
  String get fiveMinutes;

  /// No description provided for @stopSession.
  ///
  /// In en, this message translates to:
  /// **'Stop Session'**
  String get stopSession;

  /// No description provided for @phaseOf.
  ///
  /// In en, this message translates to:
  /// **'Phase {phase} of 6'**
  String phaseOf(Object phase);

  /// No description provided for @helpCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenterTitle;

  /// No description provided for @helpCenterContent.
  ///
  /// In en, this message translates to:
  /// **'SeaSmart is your AI-powered mental health companion. Use the daily check-in to track your mood, chat with our AI assistant, and explore relaxation activities.\n\nFor additional support, please contact your healthcare provider.'**
  String get helpCenterContent;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'SeaSmart Privacy Policy\n\n• Your data is stored locally on your device\n• We do not share personal information with third parties\n• Chat conversations are processed securely\n• You can delete your data anytime from the app\n\nTerms of Service\n\n• This app is for wellness support, not medical diagnosis\n• Always consult healthcare professionals for serious concerns\n• Use responsibly and as part of a comprehensive wellness plan'**
  String get privacyPolicyContent;

  /// No description provided for @appVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersionTitle;

  /// No description provided for @appVersionContent.
  ///
  /// In en, this message translates to:
  /// **'SeaSmart v1.0.0\n\nYour AI-powered mental health companion\nBuilt with Flutter & powered by AI'**
  String get appVersionContent;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully!'**
  String get languageChanged;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} feature coming soon!'**
  String featureComingSoon(Object feature);

  /// No description provided for @seaSmart.
  ///
  /// In en, this message translates to:
  /// **'Sea Smart'**
  String get seaSmart;

  /// No description provided for @poweredByStriveHigh.
  ///
  /// In en, this message translates to:
  /// **'Powered by StriveHigh'**
  String get poweredByStriveHigh;

  /// No description provided for @chooseYourCompanion.
  ///
  /// In en, this message translates to:
  /// **'Choose your companion'**
  String get chooseYourCompanion;

  /// No description provided for @avatarDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick the buddy who\'ll sail alongside you on this journey. Each one is here to guide, support, and grow with you.'**
  String get avatarDescription;

  /// No description provided for @bellyBreathing.
  ///
  /// In en, this message translates to:
  /// **'Belly Breathing'**
  String get bellyBreathing;

  /// No description provided for @bellyBreathingDescription.
  ///
  /// In en, this message translates to:
  /// **'Deep diaphragmatic breathing to reduce stress and anxiety'**
  String get bellyBreathingDescription;

  /// No description provided for @inhaleSlowly.
  ///
  /// In en, this message translates to:
  /// **'Inhale slowly'**
  String get inhaleSlowly;

  /// No description provided for @holdGently.
  ///
  /// In en, this message translates to:
  /// **'Hold gently'**
  String get holdGently;

  /// No description provided for @exhaleSlowly.
  ///
  /// In en, this message translates to:
  /// **'Exhale slowly'**
  String get exhaleSlowly;

  /// No description provided for @bellyQuote1.
  ///
  /// In en, this message translates to:
  /// **'Breathe deep into your belly, let peace fill you 🌸'**
  String get bellyQuote1;

  /// No description provided for @bellyQuote2.
  ///
  /// In en, this message translates to:
  /// **'Feel your diaphragm expand with each breath ✨'**
  String get bellyQuote2;

  /// No description provided for @bellyQuote3.
  ///
  /// In en, this message translates to:
  /// **'Deep belly breathing calms your nervous system 🧘‍♀️'**
  String get bellyQuote3;

  /// No description provided for @bellyQuote4.
  ///
  /// In en, this message translates to:
  /// **'Let your belly rise and fall naturally 💫'**
  String get bellyQuote4;

  /// No description provided for @bellyQuote5.
  ///
  /// In en, this message translates to:
  /// **'Connect with your breath, connect with peace 🕊️'**
  String get bellyQuote5;

  /// No description provided for @boxBreathing.
  ///
  /// In en, this message translates to:
  /// **'Box Breathing'**
  String get boxBreathing;

  /// No description provided for @boxBreathingDescription.
  ///
  /// In en, this message translates to:
  /// **'4-4-4-4 pattern used by Navy SEALs for focus and calm'**
  String get boxBreathingDescription;

  /// No description provided for @inhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get inhale;

  /// No description provided for @exhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get exhale;

  /// No description provided for @boxPhaseOf.
  ///
  /// In en, this message translates to:
  /// **'Phase {phase} of 4'**
  String boxPhaseOf(Object phase);

  /// No description provided for @boxQuote1.
  ///
  /// In en, this message translates to:
  /// **'4-4-4-4 breathing brings perfect balance ⬜'**
  String get boxQuote1;

  /// No description provided for @boxQuote2.
  ///
  /// In en, this message translates to:
  /// **'Navy SEALs use this technique for focus 🎯'**
  String get boxQuote2;

  /// No description provided for @boxQuote3.
  ///
  /// In en, this message translates to:
  /// **'Equal timing, equal calm ✨'**
  String get boxQuote3;

  /// No description provided for @boxQuote4.
  ///
  /// In en, this message translates to:
  /// **'Box breathing creates mental clarity 🧘‍♀️'**
  String get boxQuote4;

  /// No description provided for @boxQuote5.
  ///
  /// In en, this message translates to:
  /// **'Structured breathing for structured mind 💫'**
  String get boxQuote5;

  /// No description provided for @breathingTechniques.
  ///
  /// In en, this message translates to:
  /// **'Breathing Techniques'**
  String get breathingTechniques;

  /// No description provided for @chooseBreathingTechnique.
  ///
  /// In en, this message translates to:
  /// **'Choose a breathing technique that resonates with you 🌿'**
  String get chooseBreathingTechnique;

  /// No description provided for @chooseYourBreathingTechnique.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Breathing Technique'**
  String get chooseYourBreathingTechnique;

  /// No description provided for @selectTechnique.
  ///
  /// In en, this message translates to:
  /// **'Select a technique that resonates with you'**
  String get selectTechnique;

  /// No description provided for @certificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get certificates;

  /// No description provided for @yourAchievements.
  ///
  /// In en, this message translates to:
  /// **'Your Achievements'**
  String get yourAchievements;

  /// No description provided for @celebrateProgress.
  ///
  /// In en, this message translates to:
  /// **'Celebrate your progress and milestones'**
  String get celebrateProgress;

  /// No description provided for @loadingCertificates.
  ///
  /// In en, this message translates to:
  /// **'Loading your certificates...'**
  String get loadingCertificates;

  /// No description provided for @noCertificates.
  ///
  /// In en, this message translates to:
  /// **'You not have any Certificates!'**
  String get noCertificates;

  /// No description provided for @failedLoadCertificates.
  ///
  /// In en, this message translates to:
  /// **'Failed to load certificates. Please try again later.'**
  String get failedLoadCertificates;

  /// No description provided for @errorLoadingCertificates.
  ///
  /// In en, this message translates to:
  /// **'Error loading certificates: {error}'**
  String errorLoadingCertificates(Object error);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noCertificatesYet.
  ///
  /// In en, this message translates to:
  /// **'No Certificates Yet'**
  String get noCertificatesYet;

  /// No description provided for @completeCourses.
  ///
  /// In en, this message translates to:
  /// **'Complete courses and assessments to earn your first certificate!'**
  String get completeCourses;

  /// No description provided for @earnedCertificates.
  ///
  /// In en, this message translates to:
  /// **'Earned Certificates'**
  String get earnedCertificates;

  /// No description provided for @achievementEarned.
  ///
  /// In en, this message translates to:
  /// **'Achievement earned through dedication and hard work'**
  String get achievementEarned;

  /// No description provided for @soarPdfSaved.
  ///
  /// In en, this message translates to:
  /// **'SOAR Card PDF successfully saved. Opening now...'**
  String get soarPdfSaved;

  /// No description provided for @failedSavePdf.
  ///
  /// In en, this message translates to:
  /// **'Failed to save PDF: {error}'**
  String failedSavePdf(Object error);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @drive.
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get drive;

  /// No description provided for @certificateImageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Certificate image not available'**
  String get certificateImageNotAvailable;

  /// No description provided for @earnedOn.
  ///
  /// In en, this message translates to:
  /// **'Earned on: {date}'**
  String earnedOn(Object date);

  /// No description provided for @certificateDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Certificate downloaded successfully to {path}'**
  String certificateDownloaded(Object path);

  /// No description provided for @failedDownloadCertificate.
  ///
  /// In en, this message translates to:
  /// **'Failed to download certificate. Please try again.'**
  String get failedDownloadCertificate;

  /// No description provided for @errorDownloadingCertificate.
  ///
  /// In en, this message translates to:
  /// **'Error downloading certificate: {error}'**
  String errorDownloadingCertificate(Object error);

  /// No description provided for @shareCertificateText.
  ///
  /// In en, this message translates to:
  /// **'Check out my certificate: {name} - Achievement earned through dedication and hard work!'**
  String shareCertificateText(Object name);

  /// No description provided for @sharingCertificate.
  ///
  /// In en, this message translates to:
  /// **'Sharing certificate image...'**
  String get sharingCertificate;

  /// No description provided for @googleDriveIntegration.
  ///
  /// In en, this message translates to:
  /// **'Google Drive integration will be available in the full version!'**
  String get googleDriveIntegration;

  /// No description provided for @userEmailNotFound.
  ///
  /// In en, this message translates to:
  /// **'User email not found. Please complete your profile.'**
  String get userEmailNotFound;

  /// No description provided for @certificateInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Certificate Information'**
  String get certificateInfoTitle;

  /// No description provided for @certificateInfoSeparator.
  ///
  /// In en, this message translates to:
  /// **'====================='**
  String get certificateInfoSeparator;

  /// No description provided for @certificateInfoTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title:'**
  String get certificateInfoTitleLabel;

  /// No description provided for @certificateInfoDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get certificateInfoDescriptionLabel;

  /// No description provided for @certificateInfoCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category:'**
  String get certificateInfoCategoryLabel;

  /// No description provided for @certificateInfoEarnedDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Earned Date:'**
  String get certificateInfoEarnedDateLabel;

  /// No description provided for @certificateInfoNA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get certificateInfoNA;

  /// No description provided for @certificateInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'This certificate was earned through dedication and hard work.'**
  String get certificateInfoDescription;

  /// No description provided for @myCertificateSubject.
  ///
  /// In en, this message translates to:
  /// **'My Certificate: {title}'**
  String myCertificateSubject(Object title);

  /// No description provided for @readyForTodaysJourney.
  ///
  /// In en, this message translates to:
  /// **'Ready for today\'s journey, {userName}'**
  String readyForTodaysJourney(Object userName);

  /// No description provided for @dayAtSea.
  ///
  /// In en, this message translates to:
  /// **'Day at Sea'**
  String get dayAtSea;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @knowTab.
  ///
  /// In en, this message translates to:
  /// **'Know'**
  String get knowTab;

  /// No description provided for @growTab.
  ///
  /// In en, this message translates to:
  /// **'Grow'**
  String get growTab;

  /// No description provided for @showTab.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get showTab;

  /// No description provided for @knowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Base'**
  String get knowledgeBase;

  /// No description provided for @soarAssessment.
  ///
  /// In en, this message translates to:
  /// **'SOAR Assessment'**
  String get soarAssessment;

  /// No description provided for @completeYourAssessment.
  ///
  /// In en, this message translates to:
  /// **'Complete your assessment'**
  String get completeYourAssessment;

  /// No description provided for @questionsAnswered.
  ///
  /// In en, this message translates to:
  /// **'questions answered'**
  String get questionsAnswered;

  /// No description provided for @recentAnswers.
  ///
  /// In en, this message translates to:
  /// **'Recent Answers:'**
  String get recentAnswers;

  /// No description provided for @answerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer:'**
  String answerLabel(Object answer);

  /// No description provided for @andMoreAnswers.
  ///
  /// In en, this message translates to:
  /// **'and {count} more...'**
  String andMoreAnswers(Object count);

  /// No description provided for @takeSoarAssessment.
  ///
  /// In en, this message translates to:
  /// **'Take the SOAR assessment to understand your strengths and areas for growth.'**
  String get takeSoarAssessment;

  /// No description provided for @goalSetting.
  ///
  /// In en, this message translates to:
  /// **'Goal Setting'**
  String get goalSetting;

  /// No description provided for @setYourWellnessGoals.
  ///
  /// In en, this message translates to:
  /// **'Set your wellness goals'**
  String get setYourWellnessGoals;

  /// No description provided for @goalsSet.
  ///
  /// In en, this message translates to:
  /// **'goals set'**
  String get goalsSet;

  /// No description provided for @yourGoals.
  ///
  /// In en, this message translates to:
  /// **'Your Goals:'**
  String get yourGoals;

  /// No description provided for @andMoreGoals.
  ///
  /// In en, this message translates to:
  /// **'and {count} more goals...'**
  String andMoreGoals(Object count);

  /// No description provided for @setWellnessGoalsDescription.
  ///
  /// In en, this message translates to:
  /// **'Set your wellness goals to track your progress and stay motivated.'**
  String get setWellnessGoalsDescription;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @academy.
  ///
  /// In en, this message translates to:
  /// **'Academy'**
  String get academy;

  /// No description provided for @consultWithUs.
  ///
  /// In en, this message translates to:
  /// **'CONSULT WITH US!'**
  String get consultWithUs;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @tapToCalm.
  ///
  /// In en, this message translates to:
  /// **'Tap To Calm'**
  String get tapToCalm;

  /// No description provided for @tapForCalmness.
  ///
  /// In en, this message translates to:
  /// **'Tap for calmness'**
  String get tapForCalmness;

  /// No description provided for @memory.
  ///
  /// In en, this message translates to:
  /// **'MEMORY'**
  String get memory;

  /// No description provided for @wellnessTips.
  ///
  /// In en, this message translates to:
  /// **'Wellness Tips'**
  String get wellnessTips;

  /// No description provided for @findYourSpace.
  ///
  /// In en, this message translates to:
  /// **'Find Your Space'**
  String get findYourSpace;

  /// No description provided for @findYourSpaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a quiet spot on deck or in your cabin where you won\'t be disturbed'**
  String get findYourSpaceDescription;

  /// No description provided for @deepBreathing.
  ///
  /// In en, this message translates to:
  /// **'Deep Breathing'**
  String get deepBreathing;

  /// No description provided for @deepBreathingDescription.
  ///
  /// In en, this message translates to:
  /// **'Practice breathing exercises to reduce stress and improve focus'**
  String get deepBreathingDescription;

  /// No description provided for @stayActive.
  ///
  /// In en, this message translates to:
  /// **'Stay Active'**
  String get stayActive;

  /// No description provided for @stayActiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Regular movement helps maintain both physical and mental wellness'**
  String get stayActiveDescription;

  /// No description provided for @connectWithOthers.
  ///
  /// In en, this message translates to:
  /// **'Connect with Others'**
  String get connectWithOthers;

  /// No description provided for @connectWithOthersDescription.
  ///
  /// In en, this message translates to:
  /// **'Maintain social connections for emotional support and wellbeing'**
  String get connectWithOthersDescription;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// No description provided for @moodAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Mood Analysis'**
  String get moodAnalysis;

  /// No description provided for @progressReport.
  ///
  /// In en, this message translates to:
  /// **'Progress Report'**
  String get progressReport;

  /// No description provided for @steadyYourself.
  ///
  /// In en, this message translates to:
  /// **'Steady Yourself'**
  String get steadyYourself;

  /// No description provided for @steadyYourselfDescription.
  ///
  /// In en, this message translates to:
  /// **'Sit with your back against something stable to maintain balance with ship movement'**
  String get steadyYourselfDescription;

  /// No description provided for @useNaturalSounds.
  ///
  /// In en, this message translates to:
  /// **'Use Natural Sounds'**
  String get useNaturalSounds;

  /// No description provided for @useNaturalSoundsDescription.
  ///
  /// In en, this message translates to:
  /// **'Let the sound of waves and wind become part of your meditation practice'**
  String get useNaturalSoundsDescription;

  /// No description provided for @regularPractice.
  ///
  /// In en, this message translates to:
  /// **'Regular Practice'**
  String get regularPractice;

  /// No description provided for @regularPracticeDescription.
  ///
  /// In en, this message translates to:
  /// **'Even 5 minutes daily can significantly reduce stress and improve focus.'**
  String get regularPracticeDescription;

  /// No description provided for @chatWithBuddy.
  ///
  /// In en, this message translates to:
  /// **'Chat with Buddy'**
  String get chatWithBuddy;

  /// No description provided for @chatWithBuddyDescription.
  ///
  /// In en, this message translates to:
  /// **'Get personalized wellness guidance and support'**
  String get chatWithBuddyDescription;

  /// No description provided for @moodAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Mood Analytics'**
  String get moodAnalytics;

  /// No description provided for @moodAnalyticsDescription.
  ///
  /// In en, this message translates to:
  /// **'Track and analyze your mood patterns over time'**
  String get moodAnalyticsDescription;

  /// No description provided for @meditation.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get meditation;

  /// No description provided for @breathing.
  ///
  /// In en, this message translates to:
  /// **'Breathing'**
  String get breathing;

  /// No description provided for @memoryGame.
  ///
  /// In en, this message translates to:
  /// **'Memory Game'**
  String get memoryGame;

  /// No description provided for @dailyBreathingExercise.
  ///
  /// In en, this message translates to:
  /// **'Daily Breathing Exercise'**
  String get dailyBreathingExercise;

  /// No description provided for @dailyBreathingExerciseDescription.
  ///
  /// In en, this message translates to:
  /// **'Practice deep breathing for 5 minutes daily to reduce stress and anxiety.'**
  String get dailyBreathingExerciseDescription;

  /// No description provided for @stayConnected.
  ///
  /// In en, this message translates to:
  /// **'Stay Connected'**
  String get stayConnected;

  /// No description provided for @stayConnectedDescription.
  ///
  /// In en, this message translates to:
  /// **'Maintain regular contact with family and friends to combat loneliness.'**
  String get stayConnectedDescription;

  /// No description provided for @physicalActivity.
  ///
  /// In en, this message translates to:
  /// **'Physical Activity'**
  String get physicalActivity;

  /// No description provided for @physicalActivityDescription.
  ///
  /// In en, this message translates to:
  /// **'Engage in regular exercise to boost mood and maintain physical health.'**
  String get physicalActivityDescription;

  /// No description provided for @mindfulEating.
  ///
  /// In en, this message translates to:
  /// **'Mindful Eating'**
  String get mindfulEating;

  /// No description provided for @mindfulEatingDescription.
  ///
  /// In en, this message translates to:
  /// **'Pay attention to your meals and maintain a balanced diet for better wellness.'**
  String get mindfulEatingDescription;

  /// No description provided for @qualitySleep.
  ///
  /// In en, this message translates to:
  /// **'Quality Sleep'**
  String get qualitySleep;

  /// No description provided for @qualitySleepDescription.
  ///
  /// In en, this message translates to:
  /// **'Maintain a regular sleep schedule for better mental and physical health.'**
  String get qualitySleepDescription;

  /// No description provided for @expressYourself.
  ///
  /// In en, this message translates to:
  /// **'Express Yourself'**
  String get expressYourself;

  /// No description provided for @expressYourselfDescription.
  ///
  /// In en, this message translates to:
  /// **'Write in a journal or talk to someone about your feelings and experiences.'**
  String get expressYourselfDescription;

  /// No description provided for @findQuietSpace.
  ///
  /// In en, this message translates to:
  /// **'Find a Quiet Space'**
  String get findQuietSpace;

  /// No description provided for @findQuietSpaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a quiet spot on deck or in your cabin where you wont be disturbed.'**
  String get findQuietSpaceDescription;

  /// No description provided for @useNaturalSoundsDescription2.
  ///
  /// In en, this message translates to:
  /// **'Let the sound of the ocean waves and wind enhance your meditation experience.'**
  String get useNaturalSoundsDescription2;

  /// No description provided for @dailyCheckIns.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-ins'**
  String get dailyCheckIns;

  /// No description provided for @breathingSessions.
  ///
  /// In en, this message translates to:
  /// **'Breathing Sessions'**
  String get breathingSessions;

  /// No description provided for @journalEntries.
  ///
  /// In en, this message translates to:
  /// **'Journal Entries'**
  String get journalEntries;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get changeAvatar;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'fr',
    'ja',
    'ta',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ta':
      return AppLocalizationsTa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
