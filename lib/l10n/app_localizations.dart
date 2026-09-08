import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('fr')
  ];

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'It looks like you\'re not connected to the internet.'**
  String get noInternet;

  /// No description provided for @checkInternet.
  ///
  /// In en, this message translates to:
  /// **'Please verify your internet connection, then try again.'**
  String get checkInternet;

  /// No description provided for @joinMunturAiPrompt.
  ///
  /// In en, this message translates to:
  /// **'Willing to join our large MunturAi community?'**
  String get joinMunturAiPrompt;

  /// No description provided for @joinMunturAiInfo.
  ///
  /// In en, this message translates to:
  /// **'To join our wide MunturAi community, we need some information from you to better personalize your filters and guide you quickly to the profiles that best match you.'**
  String get joinMunturAiInfo;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the terms and conditions of use'**
  String get acceptTerms;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @connexionTitle.
  ///
  /// In en, this message translates to:
  /// **'1/5 - Login Information'**
  String get connexionTitle;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone (+237)'**
  String get phoneHint;

  /// No description provided for @confirmationSMSNote.
  ///
  /// In en, this message translates to:
  /// **'NB: We will send a confirmation SMS to this number'**
  String get confirmationSMSNote;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordHint;

  /// No description provided for @confirmationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Confirmation Code FL-XXXXX'**
  String get confirmationCodeHint;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @continue__.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue__;

  /// No description provided for @personalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'2/5 - Personal Information'**
  String get personalInfoTitle;

  /// No description provided for @personalInfos.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfos;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get nameHint;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get name;

  /// No description provided for @surnameHint.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get surnameHint;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @birthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get birthDateLabel;

  /// No description provided for @whatDoYouDo.
  ///
  /// In en, this message translates to:
  /// **'What do you do in life?'**
  String get whatDoYouDo;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @entrepreneurship.
  ///
  /// In en, this message translates to:
  /// **'Entrepreneurship'**
  String get entrepreneurship;

  /// No description provided for @nothingYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing for now'**
  String get nothingYet;

  /// No description provided for @companyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyNameHint;

  /// No description provided for @jobTitleHint.
  ///
  /// In en, this message translates to:
  /// **'What is your position?'**
  String get jobTitleHint;

  /// No description provided for @highestEducationQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is your highest level of education?'**
  String get highestEducationQuestion;

  /// No description provided for @highSchool.
  ///
  /// In en, this message translates to:
  /// **'High School'**
  String get highSchool;

  /// No description provided for @university.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get university;

  /// No description provided for @universityDegree.
  ///
  /// In en, this message translates to:
  /// **'University Degree'**
  String get universityDegree;

  /// No description provided for @schoolNameHint.
  ///
  /// In en, this message translates to:
  /// **'School Name'**
  String get schoolNameHint;

  /// No description provided for @childrenQuestion.
  ///
  /// In en, this message translates to:
  /// **'What about children?'**
  String get childrenQuestion;

  /// No description provided for @childrenSomeday.
  ///
  /// In en, this message translates to:
  /// **'I’d like to someday'**
  String get childrenSomeday;

  /// No description provided for @childrenHave.
  ///
  /// In en, this message translates to:
  /// **'I already have'**
  String get childrenHave;

  /// No description provided for @childrenNone.
  ///
  /// In en, this message translates to:
  /// **'I don’t want any'**
  String get childrenNone;

  /// No description provided for @otherLanguagesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you speak other languages?'**
  String get otherLanguagesQuestion;

  /// No description provided for @otherLanguages.
  ///
  /// In en, this message translates to:
  /// **'Other languages'**
  String get otherLanguages;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get langGerman;

  /// No description provided for @langSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get langSpanish;

  /// No description provided for @langArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get langArabic;

  /// No description provided for @langFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get langFrench;

  /// No description provided for @langChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get langChinese;

  /// No description provided for @langSwahili.
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get langSwahili;

  /// No description provided for @langOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get langOther;

  /// No description provided for @religionQuestion.
  ///
  /// In en, this message translates to:
  /// **'What religion do you practice?'**
  String get religionQuestion;

  /// No description provided for @religionAtheist.
  ///
  /// In en, this message translates to:
  /// **'Atheist'**
  String get religionAtheist;

  /// No description provided for @religionCatholic.
  ///
  /// In en, this message translates to:
  /// **'Catholic'**
  String get religionCatholic;

  /// No description provided for @religionChristian.
  ///
  /// In en, this message translates to:
  /// **'Christian'**
  String get religionChristian;

  /// No description provided for @religionMuslim.
  ///
  /// In en, this message translates to:
  /// **'Muslim'**
  String get religionMuslim;

  /// No description provided for @religionJewish.
  ///
  /// In en, this message translates to:
  /// **'Jewish'**
  String get religionJewish;

  /// No description provided for @religionAnimist.
  ///
  /// In en, this message translates to:
  /// **'Animist'**
  String get religionAnimist;

  /// No description provided for @meetTitle.
  ///
  /// In en, this message translates to:
  /// **'3/5 - Dating'**
  String get meetTitle;

  /// No description provided for @describeYourself.
  ///
  /// In en, this message translates to:
  /// **'How would you describe yourself?'**
  String get describeYourself;

  /// No description provided for @whatMakesYouUniqueHint.
  ///
  /// In en, this message translates to:
  /// **'What makes you unique?'**
  String get whatMakesYouUniqueHint;

  /// No description provided for @whatAreYouLookingFor.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get whatAreYouLookingFor;

  /// No description provided for @lookingDating.
  ///
  /// In en, this message translates to:
  /// **'Dating'**
  String get lookingDating;

  /// No description provided for @lookingChat.
  ///
  /// In en, this message translates to:
  /// **'Chatting'**
  String get lookingChat;

  /// No description provided for @lookingSerious.
  ///
  /// In en, this message translates to:
  /// **'A serious relationship'**
  String get lookingSerious;

  /// No description provided for @addPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Add photos to your profile'**
  String get addPhotosTitle;

  /// No description provided for @my_album.
  ///
  /// In en, this message translates to:
  /// **'My Album'**
  String get my_album;

  /// No description provided for @addPhotosButton.
  ///
  /// In en, this message translates to:
  /// **'Add Photos and Videos'**
  String get addPhotosButton;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @step4Title.
  ///
  /// In en, this message translates to:
  /// **'4/5 - Additional Information'**
  String get step4Title;

  /// No description provided for @personalityQuestion.
  ///
  /// In en, this message translates to:
  /// **'What personality best describes you?'**
  String get personalityQuestion;

  /// No description provided for @introvert.
  ///
  /// In en, this message translates to:
  /// **'Introvert'**
  String get introvert;

  /// No description provided for @extrovert.
  ///
  /// In en, this message translates to:
  /// **'Extrovert'**
  String get extrovert;

  /// No description provided for @bothPersonalities.
  ///
  /// In en, this message translates to:
  /// **'A bit of both'**
  String get bothPersonalities;

  /// No description provided for @alcoholQuestion.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get alcoholQuestion;

  /// No description provided for @alcoholOccasional.
  ///
  /// In en, this message translates to:
  /// **'I drink occasionally'**
  String get alcoholOccasional;

  /// No description provided for @alcoholNever.
  ///
  /// In en, this message translates to:
  /// **'I never drink'**
  String get alcoholNever;

  /// No description provided for @alcoholOften.
  ///
  /// In en, this message translates to:
  /// **'I drink often'**
  String get alcoholOften;

  /// No description provided for @alcoholStopped.
  ///
  /// In en, this message translates to:
  /// **'I stopped drinking'**
  String get alcoholStopped;

  /// No description provided for @tobaccoQuestion.
  ///
  /// In en, this message translates to:
  /// **'Tobacco'**
  String get tobaccoQuestion;

  /// No description provided for @tobaccoOften.
  ///
  /// In en, this message translates to:
  /// **'I smoke often'**
  String get tobaccoOften;

  /// No description provided for @tobaccoNever.
  ///
  /// In en, this message translates to:
  /// **'I never smoke'**
  String get tobaccoNever;

  /// No description provided for @astrologyQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is your zodiac sign?'**
  String get astrologyQuestion;

  /// No description provided for @aries.
  ///
  /// In en, this message translates to:
  /// **'Aries'**
  String get aries;

  /// No description provided for @taurus.
  ///
  /// In en, this message translates to:
  /// **'Taurus'**
  String get taurus;

  /// No description provided for @gemini.
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get gemini;

  /// No description provided for @cancer.
  ///
  /// In en, this message translates to:
  /// **'Cancer'**
  String get cancer;

  /// No description provided for @leo.
  ///
  /// In en, this message translates to:
  /// **'Leo'**
  String get leo;

  /// No description provided for @virgo.
  ///
  /// In en, this message translates to:
  /// **'Virgo'**
  String get virgo;

  /// No description provided for @libra.
  ///
  /// In en, this message translates to:
  /// **'Libra'**
  String get libra;

  /// No description provided for @scorpio.
  ///
  /// In en, this message translates to:
  /// **'Scorpio'**
  String get scorpio;

  /// No description provided for @sagittarius.
  ///
  /// In en, this message translates to:
  /// **'Sagittarius'**
  String get sagittarius;

  /// No description provided for @capricorn.
  ///
  /// In en, this message translates to:
  /// **'Capricorn'**
  String get capricorn;

  /// No description provided for @aquarius.
  ///
  /// In en, this message translates to:
  /// **'Aquarius'**
  String get aquarius;

  /// No description provided for @pisces.
  ///
  /// In en, this message translates to:
  /// **'Pisces'**
  String get pisces;

  /// No description provided for @hobbiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the topics that interest you!'**
  String get hobbiesTitle;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @progressHint.
  ///
  /// In en, this message translates to:
  /// **'Just a few moments and it will be done...'**
  String get progressHint;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start a chat'**
  String get startChat;

  /// No description provided for @dotheFirstStep.
  ///
  /// In en, this message translates to:
  /// **'Do the first step !'**
  String get dotheFirstStep;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeen;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get blockUser;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get reportUser;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @about_me.
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get about_me;

  /// No description provided for @more_about_me.
  ///
  /// In en, this message translates to:
  /// **'More about me'**
  String get more_about_me;

  /// No description provided for @my_languages.
  ///
  /// In en, this message translates to:
  /// **'My Languages'**
  String get my_languages;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get months;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ai_matching_title.
  ///
  /// In en, this message translates to:
  /// **'AI Matching'**
  String get ai_matching_title;

  /// No description provided for @ai_matching_description.
  ///
  /// In en, this message translates to:
  /// **'Our platform uses cutting-edge technology to ensure you get the best possible matches.'**
  String get ai_matching_description;

  /// No description provided for @matches_title.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches_title;

  /// No description provided for @matches_description.
  ///
  /// In en, this message translates to:
  /// **'View your compatible matches and start building meaningful connections today.'**
  String get matches_description;

  /// No description provided for @premium_title.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium_title;

  /// No description provided for @premium_description.
  ///
  /// In en, this message translates to:
  /// **'Unlock exclusive features with Premium and maximize your chances of finding the ideal person.'**
  String get premium_description;

  /// No description provided for @create_account.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get create_account;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get already_have_account;

  /// No description provided for @login_here.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login_here;

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_title;

  /// No description provided for @showLikes.
  ///
  /// In en, this message translates to:
  /// **'Show my likes'**
  String get showLikes;

  /// No description provided for @email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email_label;

  /// No description provided for @password_hint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_hint;

  /// No description provided for @password_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get password_label;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot_password;

  /// No description provided for @invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email!'**
  String get invalid_email;

  /// No description provided for @invalid_credentials.
  ///
  /// In en, this message translates to:
  /// **'Please check your login information!'**
  String get invalid_credentials;

  /// No description provided for @login_failed.
  ///
  /// In en, this message translates to:
  /// **'Login failed! Please try again'**
  String get login_failed;

  /// No description provided for @login_button.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_button;

  /// No description provided for @or_separator.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or_separator;

  /// No description provided for @recover_account.
  ///
  /// In en, this message translates to:
  /// **'Recover my account'**
  String get recover_account;

  /// No description provided for @login_failed_snackbar.
  ///
  /// In en, this message translates to:
  /// **'login failed'**
  String get login_failed_snackbar;

  /// No description provided for @login_failed_snackbar_alt.
  ///
  /// In en, this message translates to:
  /// **'login failed!'**
  String get login_failed_snackbar_alt;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @subscription_free.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get subscription_free;

  /// No description provided for @subscription_expiry.
  ///
  /// In en, this message translates to:
  /// **'Expires on: --/--/--'**
  String get subscription_expiry;

  /// No description provided for @subscription_premium.
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get subscription_premium;

  /// No description provided for @subscription_premium_desc.
  ///
  /// In en, this message translates to:
  /// **'Swipe as much as you want and boost your match chances by 20%!'**
  String get subscription_premium_desc;

  /// No description provided for @subscription_premium_upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade from 2000 Fcfa'**
  String get subscription_premium_upgrade;

  /// No description provided for @subscription_gold.
  ///
  /// In en, this message translates to:
  /// **'Gold Plan'**
  String get subscription_gold;

  /// No description provided for @subscription_gold_desc.
  ///
  /// In en, this message translates to:
  /// **'Enjoy all Premium benefits and even more features to increase your chances!'**
  String get subscription_gold_desc;

  /// No description provided for @subscription_gold_upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade from 3500 Fcfa'**
  String get subscription_gold_upgrade;

  /// No description provided for @my_account.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get my_account;

  /// No description provided for @blocked_users.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blocked_users;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// No description provided for @terms_of_use.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get terms_of_use;

  /// No description provided for @hobby_football.
  ///
  /// In en, this message translates to:
  /// **'football'**
  String get hobby_football;

  /// No description provided for @hobby_laughing.
  ///
  /// In en, this message translates to:
  /// **'laughing'**
  String get hobby_laughing;

  /// No description provided for @hobby_comedy.
  ///
  /// In en, this message translates to:
  /// **'comedy'**
  String get hobby_comedy;

  /// No description provided for @hobby_memes.
  ///
  /// In en, this message translates to:
  /// **'memes'**
  String get hobby_memes;

  /// No description provided for @hobby_sport.
  ///
  /// In en, this message translates to:
  /// **'sports'**
  String get hobby_sport;

  /// No description provided for @hobby_cinema.
  ///
  /// In en, this message translates to:
  /// **'cinema'**
  String get hobby_cinema;

  /// No description provided for @hobby_sea.
  ///
  /// In en, this message translates to:
  /// **'sea'**
  String get hobby_sea;

  /// No description provided for @hobby_travel.
  ///
  /// In en, this message translates to:
  /// **'travel'**
  String get hobby_travel;

  /// No description provided for @hobby_party.
  ///
  /// In en, this message translates to:
  /// **'party'**
  String get hobby_party;

  /// No description provided for @hobby_cooking.
  ///
  /// In en, this message translates to:
  /// **'cooking'**
  String get hobby_cooking;

  /// No description provided for @hobby_relaxation.
  ///
  /// In en, this message translates to:
  /// **'relaxation'**
  String get hobby_relaxation;

  /// No description provided for @hobby_music.
  ///
  /// In en, this message translates to:
  /// **'music'**
  String get hobby_music;

  /// No description provided for @hobby_gospel.
  ///
  /// In en, this message translates to:
  /// **'gospel'**
  String get hobby_gospel;

  /// No description provided for @hobby_novel.
  ///
  /// In en, this message translates to:
  /// **'novel'**
  String get hobby_novel;

  /// No description provided for @hobby_diy.
  ///
  /// In en, this message translates to:
  /// **'DIY'**
  String get hobby_diy;

  /// No description provided for @hobby_decor.
  ///
  /// In en, this message translates to:
  /// **'decoration'**
  String get hobby_decor;

  /// No description provided for @hobby_manicure.
  ///
  /// In en, this message translates to:
  /// **'manicure'**
  String get hobby_manicure;

  /// No description provided for @hobby_pedicure.
  ///
  /// In en, this message translates to:
  /// **'pedicure'**
  String get hobby_pedicure;

  /// No description provided for @hobby_shopping.
  ///
  /// In en, this message translates to:
  /// **'shopping'**
  String get hobby_shopping;

  /// No description provided for @hobby_self_motivation.
  ///
  /// In en, this message translates to:
  /// **'self-motivation'**
  String get hobby_self_motivation;

  /// No description provided for @hobby_news.
  ///
  /// In en, this message translates to:
  /// **'news'**
  String get hobby_news;

  /// No description provided for @hobby_social_media.
  ///
  /// In en, this message translates to:
  /// **'social media'**
  String get hobby_social_media;

  /// No description provided for @hobby_tiktok.
  ///
  /// In en, this message translates to:
  /// **'Tiktok'**
  String get hobby_tiktok;

  /// No description provided for @hobby_instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get hobby_instagram;

  /// No description provided for @hobby_love.
  ///
  /// In en, this message translates to:
  /// **'love'**
  String get hobby_love;

  /// No description provided for @hobby_friendship.
  ///
  /// In en, this message translates to:
  /// **'friendship'**
  String get hobby_friendship;

  /// No description provided for @filters_title.
  ///
  /// In en, this message translates to:
  /// **'More Filters'**
  String get filters_title;

  /// No description provided for @filters_clear_all.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get filters_clear_all;

  /// No description provided for @filters_premium_required.
  ///
  /// In en, this message translates to:
  /// **'To use these filters, you need to activate Premium subscription.'**
  String get filters_premium_required;

  /// No description provided for @filters_your_preferences.
  ///
  /// In en, this message translates to:
  /// **'Your Preferences'**
  String get filters_your_preferences;

  /// No description provided for @filters_verified_profiles.
  ///
  /// In en, this message translates to:
  /// **'Verified Profiles'**
  String get filters_verified_profiles;

  /// No description provided for @filters_verified_profiles_only.
  ///
  /// In en, this message translates to:
  /// **'Only verified profiles'**
  String get filters_verified_profiles_only;

  /// No description provided for @filters_height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get filters_height;

  /// No description provided for @filters_here_for.
  ///
  /// In en, this message translates to:
  /// **'Here for'**
  String get filters_here_for;

  /// No description provided for @filters_astrology_sign.
  ///
  /// In en, this message translates to:
  /// **'Astrology Sign'**
  String get filters_astrology_sign;

  /// No description provided for @filters_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get filters_language;

  /// No description provided for @filters_children.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get filters_children;

  /// No description provided for @filters_pets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get filters_pets;

  /// No description provided for @filters_smoke.
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get filters_smoke;

  /// No description provided for @filters_alcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get filters_alcohol;

  /// No description provided for @filters_studies.
  ///
  /// In en, this message translates to:
  /// **'Studies'**
  String get filters_studies;

  /// No description provided for @filters_religion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get filters_religion;

  /// No description provided for @filters_love_status.
  ///
  /// In en, this message translates to:
  /// **'Love Status'**
  String get filters_love_status;

  /// No description provided for @filters_personality.
  ///
  /// In en, this message translates to:
  /// **'Personality'**
  String get filters_personality;

  /// No description provided for @filters_hobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get filters_hobbies;

  /// No description provided for @filters_popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get filters_popular;

  /// No description provided for @filters_verified_profiles_desc.
  ///
  /// In en, this message translates to:
  /// **'To ensure you\'re liking real profiles'**
  String get filters_verified_profiles_desc;

  /// No description provided for @filters_height_desc.
  ///
  /// In en, this message translates to:
  /// **'Find someone who’s the right height for you'**
  String get filters_height_desc;

  /// No description provided for @filters_here_for_desc.
  ///
  /// In en, this message translates to:
  /// **'Looking for casual dating... or a serious relationship?'**
  String get filters_here_for_desc;

  /// No description provided for @filters_astrology_desc.
  ///
  /// In en, this message translates to:
  /// **'Meet those whose stars align best with yours'**
  String get filters_astrology_desc;

  /// No description provided for @filters_language_desc.
  ///
  /// In en, this message translates to:
  /// **'Connect without language barriers'**
  String get filters_language_desc;

  /// No description provided for @filters_lifestyle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get filters_lifestyle;

  /// No description provided for @filters_kids_desc.
  ///
  /// In en, this message translates to:
  /// **'Should they have children?'**
  String get filters_kids_desc;

  /// No description provided for @filters_pets_desc.
  ///
  /// In en, this message translates to:
  /// **'How do they feel about pets?'**
  String get filters_pets_desc;

  /// No description provided for @filters_smoke_desc.
  ///
  /// In en, this message translates to:
  /// **'Would you accept a bit of smoke?'**
  String get filters_smoke_desc;

  /// No description provided for @filters_alcohol_desc.
  ///
  /// In en, this message translates to:
  /// **'Maybe to toast together?'**
  String get filters_alcohol_desc;

  /// No description provided for @filters_studies_desc.
  ///
  /// In en, this message translates to:
  /// **'What education level attracts you?'**
  String get filters_studies_desc;

  /// No description provided for @filters_religion_desc.
  ///
  /// In en, this message translates to:
  /// **'And what about their religion...'**
  String get filters_religion_desc;

  /// No description provided for @filters_love_status_desc.
  ///
  /// In en, this message translates to:
  /// **'To meet singles... or not'**
  String get filters_love_status_desc;

  /// No description provided for @filters_personality_desc.
  ///
  /// In en, this message translates to:
  /// **'People who are just like you... or totally different!'**
  String get filters_personality_desc;

  /// No description provided for @filters_hobbies_desc.
  ///
  /// In en, this message translates to:
  /// **'What do they think of having pets?'**
  String get filters_hobbies_desc;

  /// No description provided for @filters_expanded_results_info.
  ///
  /// In en, this message translates to:
  /// **'If no one matches your criteria, we’ll show slightly different profiles.'**
  String get filters_expanded_results_info;

  /// No description provided for @filters_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get filters_apply;

  /// No description provided for @filter_verified_profiles_title.
  ///
  /// In en, this message translates to:
  /// **'Verified Profiles'**
  String get filter_verified_profiles_title;

  /// No description provided for @filter_verified_profiles_description.
  ///
  /// In en, this message translates to:
  /// **'To ensure you\'re liking real profiles'**
  String get filter_verified_profiles_description;

  /// No description provided for @filter_verified_profiles_only.
  ///
  /// In en, this message translates to:
  /// **'Only verified profiles'**
  String get filter_verified_profiles_only;

  /// No description provided for @filter_ok_button.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get filter_ok_button;

  /// No description provided for @filter_height_title.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get filter_height_title;

  /// No description provided for @filter_height_description.
  ///
  /// In en, this message translates to:
  /// **'Find someone who’s the right height for you'**
  String get filter_height_description;

  /// No description provided for @filter_no_minimum.
  ///
  /// In en, this message translates to:
  /// **'No minimum'**
  String get filter_no_minimum;

  /// No description provided for @filter_no_maximum.
  ///
  /// In en, this message translates to:
  /// **'No maximum'**
  String get filter_no_maximum;

  /// No description provided for @filter_here_for_title.
  ///
  /// In en, this message translates to:
  /// **'You\'re here for'**
  String get filter_here_for_title;

  /// No description provided for @filter_here_for_description.
  ///
  /// In en, this message translates to:
  /// **'(Choose as many as you want)'**
  String get filter_here_for_description;

  /// No description provided for @filter_option_dating.
  ///
  /// In en, this message translates to:
  /// **'Dating'**
  String get filter_option_dating;

  /// No description provided for @filter_option_relationship.
  ///
  /// In en, this message translates to:
  /// **'Serious Relationship'**
  String get filter_option_relationship;

  /// No description provided for @filter_option_chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get filter_option_chat;

  /// No description provided for @filter_astrology_title.
  ///
  /// In en, this message translates to:
  /// **'Astrology Sign'**
  String get filter_astrology_title;

  /// No description provided for @filter_astrology_description.
  ///
  /// In en, this message translates to:
  /// **'Looking for a specific sign?'**
  String get filter_astrology_description;

  /// No description provided for @filter_astrology_aries.
  ///
  /// In en, this message translates to:
  /// **'Aries'**
  String get filter_astrology_aries;

  /// No description provided for @filter_astrology_taurus.
  ///
  /// In en, this message translates to:
  /// **'Taurus'**
  String get filter_astrology_taurus;

  /// No description provided for @filter_astrology_gemini.
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get filter_astrology_gemini;

  /// No description provided for @filter_astrology_cancer.
  ///
  /// In en, this message translates to:
  /// **'Cancer'**
  String get filter_astrology_cancer;

  /// No description provided for @filter_astrology_leo.
  ///
  /// In en, this message translates to:
  /// **'Leo'**
  String get filter_astrology_leo;

  /// No description provided for @filter_astrology_virgo.
  ///
  /// In en, this message translates to:
  /// **'Virgo'**
  String get filter_astrology_virgo;

  /// No description provided for @filter_astrology_libra.
  ///
  /// In en, this message translates to:
  /// **'Libra'**
  String get filter_astrology_libra;

  /// No description provided for @filter_astrology_scorpio.
  ///
  /// In en, this message translates to:
  /// **'Scorpio'**
  String get filter_astrology_scorpio;

  /// No description provided for @filter_astrology_sagittarius.
  ///
  /// In en, this message translates to:
  /// **'Sagittarius'**
  String get filter_astrology_sagittarius;

  /// No description provided for @filter_astrology_capricorn.
  ///
  /// In en, this message translates to:
  /// **'Capricorn'**
  String get filter_astrology_capricorn;

  /// No description provided for @filter_astrology_aquarius.
  ///
  /// In en, this message translates to:
  /// **'Aquarius'**
  String get filter_astrology_aquarius;

  /// No description provided for @filter_astrology_pisces.
  ///
  /// In en, this message translates to:
  /// **'Pisces'**
  String get filter_astrology_pisces;

  /// No description provided for @filter_language_title.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get filter_language_title;

  /// No description provided for @filter_language_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Who are you looking for? What language should they speak? \n (Select as many as you want :) )'**
  String get filter_language_subtitle;

  /// No description provided for @filter_language_french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get filter_language_french;

  /// No description provided for @filter_language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get filter_language_english;

  /// No description provided for @filter_language_german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get filter_language_german;

  /// No description provided for @filter_language_spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get filter_language_spanish;

  /// No description provided for @filter_language_russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get filter_language_russian;

  /// No description provided for @filter_language_chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get filter_language_chinese;

  /// No description provided for @filter_language_swahili.
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get filter_language_swahili;

  /// No description provided for @filter_children_title.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get filter_children_title;

  /// No description provided for @filter_children_subtitle.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for regarding children? \n (Select as many as you want :) )'**
  String get filter_children_subtitle;

  /// No description provided for @filter_children_wants.
  ///
  /// In en, this message translates to:
  /// **'Wants children someday'**
  String get filter_children_wants;

  /// No description provided for @filter_children_has.
  ///
  /// In en, this message translates to:
  /// **'Already has children'**
  String get filter_children_has;

  /// No description provided for @filter_children_not_want.
  ///
  /// In en, this message translates to:
  /// **'Does not want children'**
  String get filter_children_not_want;

  /// No description provided for @filter_pets_title.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get filter_pets_title;

  /// No description provided for @filter_pets_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Are you looking for someone with pets? \n (Select as many as you want :) )'**
  String get filter_pets_subtitle;

  /// No description provided for @filter_pets_cat.
  ///
  /// In en, this message translates to:
  /// **'Cat(s)'**
  String get filter_pets_cat;

  /// No description provided for @filter_pets_dog.
  ///
  /// In en, this message translates to:
  /// **'Dog(s)'**
  String get filter_pets_dog;

  /// No description provided for @filter_pets_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get filter_pets_other;

  /// No description provided for @filter_pets_multiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple'**
  String get filter_pets_multiple;

  /// No description provided for @filter_pets_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get filter_pets_none;

  /// No description provided for @filter_smoke_title.
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get filter_smoke_title;

  /// No description provided for @filter_smoke_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re looking for someone who... \n (Select as many as you want :) )'**
  String get filter_smoke_subtitle;

  /// No description provided for @filter_smoke_no.
  ///
  /// In en, this message translates to:
  /// **'Does not smoke'**
  String get filter_smoke_no;

  /// No description provided for @filter_smoke_often.
  ///
  /// In en, this message translates to:
  /// **'Smokes often'**
  String get filter_smoke_often;

  /// No description provided for @button_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get button_ok;

  /// No description provided for @title_alcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get title_alcohol;

  /// No description provided for @desc_alcohol.
  ///
  /// In en, this message translates to:
  /// **'You\'re looking for someone who ... \n (Choose as many as you like :) )'**
  String get desc_alcohol;

  /// No description provided for @option_drinks_occasionally.
  ///
  /// In en, this message translates to:
  /// **'Drinks occasionally'**
  String get option_drinks_occasionally;

  /// No description provided for @option_never_drinks.
  ///
  /// In en, this message translates to:
  /// **'Never drinks'**
  String get option_never_drinks;

  /// No description provided for @option_drinks_often.
  ///
  /// In en, this message translates to:
  /// **'Drinks often'**
  String get option_drinks_often;

  /// No description provided for @option_no_longer_drinks.
  ///
  /// In en, this message translates to:
  /// **'No longer drinks'**
  String get option_no_longer_drinks;

  /// No description provided for @title_study.
  ///
  /// In en, this message translates to:
  /// **'Studies'**
  String get title_study;

  /// No description provided for @desc_study.
  ///
  /// In en, this message translates to:
  /// **'Are you looking for someone with a particular level of education? \n (Choose as many as you like :) )'**
  String get desc_study;

  /// No description provided for @option_high_school.
  ///
  /// In en, this message translates to:
  /// **'High school'**
  String get option_high_school;

  /// No description provided for @option_at_university.
  ///
  /// In en, this message translates to:
  /// **'In university'**
  String get option_at_university;

  /// No description provided for @option_finished_university.
  ///
  /// In en, this message translates to:
  /// **'Finished university'**
  String get option_finished_university;

  /// No description provided for @option_in_grad_school.
  ///
  /// In en, this message translates to:
  /// **'In grad school'**
  String get option_in_grad_school;

  /// No description provided for @option_graduate.
  ///
  /// In en, this message translates to:
  /// **'Graduate'**
  String get option_graduate;

  /// No description provided for @title_religion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get title_religion;

  /// No description provided for @desc_religion.
  ///
  /// In en, this message translates to:
  /// **'Are you looking for someone who practices a particular religion? \n (Choose as many as you like :) )'**
  String get desc_religion;

  /// No description provided for @option_atheist.
  ///
  /// In en, this message translates to:
  /// **'Atheist'**
  String get option_atheist;

  /// No description provided for @option_catholic.
  ///
  /// In en, this message translates to:
  /// **'Catholic'**
  String get option_catholic;

  /// No description provided for @option_christian.
  ///
  /// In en, this message translates to:
  /// **'Christian'**
  String get option_christian;

  /// No description provided for @option_jewish.
  ///
  /// In en, this message translates to:
  /// **'Jewish'**
  String get option_jewish;

  /// No description provided for @option_muslim.
  ///
  /// In en, this message translates to:
  /// **'Muslim'**
  String get option_muslim;

  /// No description provided for @option_other_religion.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get option_other_religion;

  /// No description provided for @title_love_status.
  ///
  /// In en, this message translates to:
  /// **'Relationship status'**
  String get title_love_status;

  /// No description provided for @desc_love_status.
  ///
  /// In en, this message translates to:
  /// **'You’re looking for someone who is ... \n (Choose as many as you like :) )'**
  String get desc_love_status;

  /// No description provided for @option_single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get option_single;

  /// No description provided for @option_in_relationship.
  ///
  /// In en, this message translates to:
  /// **'In a relationship'**
  String get option_in_relationship;

  /// No description provided for @option_open_relationship.
  ///
  /// In en, this message translates to:
  /// **'In an open relationship'**
  String get option_open_relationship;

  /// No description provided for @title_personality.
  ///
  /// In en, this message translates to:
  /// **'Personality'**
  String get title_personality;

  /// No description provided for @desc_personality.
  ///
  /// In en, this message translates to:
  /// **'You’re looking for someone who is ... \n (Choose as many as you like :) )'**
  String get desc_personality;

  /// No description provided for @option_extrovert.
  ///
  /// In en, this message translates to:
  /// **'Extrovert'**
  String get option_extrovert;

  /// No description provided for @option_introvert.
  ///
  /// In en, this message translates to:
  /// **'Introvert'**
  String get option_introvert;

  /// No description provided for @option_both.
  ///
  /// In en, this message translates to:
  /// **'A bit of both'**
  String get option_both;

  /// No description provided for @title_hobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get title_hobbies;

  /// No description provided for @desc_hobbies.
  ///
  /// In en, this message translates to:
  /// **'You\'re looking for someone with which interests? \n (Choose as many as you like :) )'**
  String get desc_hobbies;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @discover_likes.
  ///
  /// In en, this message translates to:
  /// **'Discover people who liked you'**
  String get discover_likes;

  /// No description provided for @info_premium_gold.
  ///
  /// In en, this message translates to:
  /// **'For more information about our Premium and Gold plans, you can consult the Terms of Use.'**
  String get info_premium_gold;

  /// No description provided for @subscription_title.
  ///
  /// In en, this message translates to:
  /// **'MunturAi {type} Subscription {months} months'**
  String subscription_title(Object months, Object type);

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{days} Days'**
  String days(Object days);

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @price_value.
  ///
  /// In en, this message translates to:
  /// **'{price} Fcfa'**
  String price_value(Object price);

  /// No description provided for @pay_with.
  ///
  /// In en, this message translates to:
  /// **'Pay with Mobile Money'**
  String get pay_with;

  /// No description provided for @momo_placeholder.
  ///
  /// In en, this message translates to:
  /// **'67xxxxxxx'**
  String get momo_placeholder;

  /// No description provided for @om_placeholder.
  ///
  /// In en, this message translates to:
  /// **'69xxxxxxx'**
  String get om_placeholder;

  /// No description provided for @active_subscription_warning.
  ///
  /// In en, this message translates to:
  /// **'Any new subscription will not cancel or stop the previous one. The active subscription will be the highest one. For more information about our Premium and Gold plans, you can consult the Terms of Use.'**
  String get active_subscription_warning;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @about_title.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about_title;

  /// No description provided for @version_label.
  ///
  /// In en, this message translates to:
  /// **'Version: 5.11723.55'**
  String get version_label;

  /// No description provided for @build_date_label.
  ///
  /// In en, this message translates to:
  /// **'Build date: 03/09/2024'**
  String get build_date_label;

  /// No description provided for @copyright_label.
  ///
  /// In en, this message translates to:
  /// **'Copyright - 2025 STEPS INDUSTRIES. All rights reserved.'**
  String get copyright_label;

  /// No description provided for @logout_title.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout_title;

  /// No description provided for @logout_prompt.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do?'**
  String get logout_prompt;

  /// No description provided for @logout_hide_account.
  ///
  /// In en, this message translates to:
  /// **'Hide my account'**
  String get logout_hide_account;

  /// No description provided for @logout_hide_account_description.
  ///
  /// In en, this message translates to:
  /// **'In case you want to take a break for a while.'**
  String get logout_hide_account_description;

  /// No description provided for @logout_button.
  ///
  /// In en, this message translates to:
  /// **'Log me out'**
  String get logout_button;

  /// No description provided for @logout_delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get logout_delete_account;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @encounters.
  ///
  /// In en, this message translates to:
  /// **'Encounters'**
  String get encounters;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likes;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get conversations;

  /// No description provided for @likesAdvice.
  ///
  /// In en, this message translates to:
  /// **'The sooner you return a Like, the better your chances of chatting and meeting up!'**
  String get likesAdvice;

  /// No description provided for @current_mood_question.
  ///
  /// In en, this message translates to:
  /// **'What\'s your current mood?'**
  String get current_mood_question;

  /// No description provided for @share_feelings.
  ///
  /// In en, this message translates to:
  /// **'Share how you feel right now'**
  String get share_feelings;

  /// No description provided for @unknown_mood.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get unknown_mood;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @select_gender_prompt.
  ///
  /// In en, this message translates to:
  /// **'Who do you want to meet?'**
  String get select_gender_prompt;

  /// No description provided for @gender_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get gender_male;

  /// No description provided for @gender_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get gender_female;

  /// No description provided for @gender_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get gender_all;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @age_range.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get age_range;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance (Km)'**
  String get distance;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @apply_filters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get apply_filters;

  /// No description provided for @more_options.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get more_options;

  /// No description provided for @filter_location_question.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to search?'**
  String get filter_location_question;

  /// No description provided for @nearby_location.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby_location;

  /// No description provided for @enter_city_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter a city'**
  String get enter_city_hint;

  /// No description provided for @match_title.
  ///
  /// In en, this message translates to:
  /// **'It\'s a match!!!'**
  String get match_title;

  /// No description provided for @match_description.
  ///
  /// In en, this message translates to:
  /// **'Maybe this time it\'s the right one! \n Get to know each other and give it a shot !!!)'**
  String get match_description;

  /// No description provided for @send_hi.
  ///
  /// In en, this message translates to:
  /// **'Send a hi'**
  String get send_hi;

  /// No description provided for @step1_title.
  ///
  /// In en, this message translates to:
  /// **'1/2 -  Login Information'**
  String get step1_title;

  /// No description provided for @step2_title.
  ///
  /// In en, this message translates to:
  /// **'2/2 -  Password Reset'**
  String get step2_title;

  /// No description provided for @hint_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get hint_phone;

  /// No description provided for @hint_confirmation_code.
  ///
  /// In en, this message translates to:
  /// **'Confirmation Code FL-XXXXX'**
  String get hint_confirmation_code;

  /// No description provided for @hint_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get hint_password;

  /// No description provided for @hint_password_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get hint_password_confirm;

  /// No description provided for @note_sms.
  ///
  /// In en, this message translates to:
  /// **'NB: We will send a confirmation SMS to this number'**
  String get note_sms;

  /// No description provided for @button_send_code.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get button_send_code;

  /// No description provided for @button_verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get button_verify;

  /// No description provided for @button_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get button_back;

  /// No description provided for @button_finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get button_finish;

  /// No description provided for @error_code_incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code'**
  String get error_code_incorrect;

  /// No description provided for @error_invalid_phone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get error_invalid_phone;

  /// No description provided for @error_password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Fields are not correctly filled! Please follow the instruction!'**
  String get error_password_mismatch;

  /// No description provided for @success_reset_password.
  ///
  /// In en, this message translates to:
  /// **'Congratulations !!!! \n You have successfully reset your password!'**
  String get success_reset_password;

  /// No description provided for @popularity_title.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get popularity_title;

  /// No description provided for @your_activity.
  ///
  /// In en, this message translates to:
  /// **'Your activity'**
  String get your_activity;

  /// No description provided for @likes_label.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likes_label;

  /// No description provided for @favorites_label.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites_label;

  /// No description provided for @month_label.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get month_label;

  /// No description provided for @new_likes.
  ///
  /// In en, this message translates to:
  /// **'0 New Likes'**
  String get new_likes;

  /// No description provided for @new_favorites.
  ///
  /// In en, this message translates to:
  /// **'0 New Favorites'**
  String get new_favorites;

  /// No description provided for @new_visits.
  ///
  /// In en, this message translates to:
  /// **'0 New Visits'**
  String get new_visits;

  /// No description provided for @boost_activity_title.
  ///
  /// In en, this message translates to:
  /// **'Boost your activity in a flash'**
  String get boost_activity_title;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @shorter_than.
  ///
  /// In en, this message translates to:
  /// **'Shorter than'**
  String get shorter_than;

  /// No description provided for @taller_than.
  ///
  /// In en, this message translates to:
  /// **'Taller than'**
  String get taller_than;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @feature_premium_see_who_liked.
  ///
  /// In en, this message translates to:
  /// **'See who liked or visited you'**
  String get feature_premium_see_who_liked;

  /// No description provided for @feature_premium_undo_swipe.
  ///
  /// In en, this message translates to:
  /// **'Undo accidental swipe'**
  String get feature_premium_undo_swipe;

  /// No description provided for @feature_premium_unlimited_likes.
  ///
  /// In en, this message translates to:
  /// **'Unlimited likes'**
  String get feature_premium_unlimited_likes;

  /// No description provided for @feature_premium_weekly_boost.
  ///
  /// In en, this message translates to:
  /// **'1 Boost per week'**
  String get feature_premium_weekly_boost;

  /// No description provided for @feature_premium_advanced_filters.
  ///
  /// In en, this message translates to:
  /// **'Advanced search filters'**
  String get feature_premium_advanced_filters;

  /// No description provided for @feature_premium_ai_suggestions.
  ///
  /// In en, this message translates to:
  /// **'AI-powered high compatibility suggestions'**
  String get feature_premium_ai_suggestions;

  /// No description provided for @feature_gold_all_premium.
  ///
  /// In en, this message translates to:
  /// **'All Premium features'**
  String get feature_gold_all_premium;

  /// No description provided for @feature_gold_message_without_match.
  ///
  /// In en, this message translates to:
  /// **'Send messages without matching'**
  String get feature_gold_message_without_match;

  /// No description provided for @feature_gold_three_boosts.
  ///
  /// In en, this message translates to:
  /// **'3 Boosts per week'**
  String get feature_gold_three_boosts;

  /// No description provided for @feature_gold_gold_badge.
  ///
  /// In en, this message translates to:
  /// **'Gold badge on profile'**
  String get feature_gold_gold_badge;

  /// No description provided for @feature_gold_priority_visibility.
  ///
  /// In en, this message translates to:
  /// **'Priority visibility in search results'**
  String get feature_gold_priority_visibility;

  /// No description provided for @feature_gold_exclusive_profiles.
  ///
  /// In en, this message translates to:
  /// **'Access to exclusive popular profiles'**
  String get feature_gold_exclusive_profiles;

  /// No description provided for @pay_with_credit_card.
  ///
  /// In en, this message translates to:
  /// **'Pay with credit card'**
  String get pay_with_credit_card;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @where_do_you_live.
  ///
  /// In en, this message translates to:
  /// **'Where do you live?'**
  String get where_do_you_live;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get readLess;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameHint;

  /// No description provided for @secondNameHint.
  ///
  /// In en, this message translates to:
  /// **'Second Name'**
  String get secondNameHint;

  /// No description provided for @countryHint.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryHint;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTitle;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @newsTitle.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get newsTitle;

  /// No description provided for @forumsTitle.
  ///
  /// In en, this message translates to:
  /// **'Forums'**
  String get forumsTitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @newDiscussion.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newDiscussion;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @chatWelcome.
  ///
  /// In en, this message translates to:
  /// **'Start a new discussion with Muntur AI,Ask me any question you want !'**
  String get chatWelcome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
