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
/// import 'arb/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('fr'),
  ];

  /// Main application title
  ///
  /// In en, this message translates to:
  /// **'ProMéca'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get appWelcome;

  /// Start button text
  ///
  /// In en, this message translates to:
  /// **'Get Started!'**
  String get appStart;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// Phone number input label
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authPhoneNumber;

  /// Password input label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// Persistent session checkbox
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get authRememberMe;

  /// Password reset link
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// Information text below form
  ///
  /// In en, this message translates to:
  /// **'If you don\'t have an account, please contact your manager.'**
  String get authLoginMessage;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Next step button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// Required field error
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errorsRequiredField;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get errorsInvalidEmail;

  /// No description provided for @completedVehicles.
  ///
  /// In en, this message translates to:
  /// **'Completed Vehicles'**
  String get completedVehicles;

  /// No description provided for @ongoingVehicles.
  ///
  /// In en, this message translates to:
  /// **'Ongoing Vehicles'**
  String get ongoingVehicles;

  /// No description provided for @repair.
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get repair;

  /// No description provided for @clientValidation.
  ///
  /// In en, this message translates to:
  /// **'Client Validation'**
  String get clientValidation;

  /// No description provided for @diagnostic.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic'**
  String get diagnostic;

  /// No description provided for @waitingDiagnotics.
  ///
  /// In en, this message translates to:
  /// **'Waiting diagnostics'**
  String get waitingDiagnotics;

  /// No description provided for @waitingValidationDiagnostic.
  ///
  /// In en, this message translates to:
  /// **'Waiting validation diagnostic'**
  String get waitingValidationDiagnostic;

  /// No description provided for @waitingValidation.
  ///
  /// In en, this message translates to:
  /// **'Wainting intervention validation'**
  String get waitingValidation;

  /// No description provided for @repairing.
  ///
  /// In en, this message translates to:
  /// **'Repairing in progress'**
  String get repairing;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @seeInvoice.
  ///
  /// In en, this message translates to:
  /// **'See Invoice'**
  String get seeInvoice;

  /// No description provided for @vehicleRegistrationHint.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration'**
  String get vehicleRegistrationHint;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @parts.
  ///
  /// In en, this message translates to:
  /// **'Engine parts'**
  String get parts;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @technicianRole.
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get technicianRole;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'add'**
  String get add;

  /// No description provided for @immatVehicule.
  ///
  /// In en, this message translates to:
  /// **'vehicle plate'**
  String get immatVehicule;

  /// No description provided for @validation.
  ///
  /// In en, this message translates to:
  /// **'In validation'**
  String get validation;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @administratorRole.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administratorRole;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateProfile;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @biographyLabel.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get biographyLabel;

  /// No description provided for @certifiedTechnician.
  ///
  /// In en, this message translates to:
  /// **'Certified Technician'**
  String get certifiedTechnician;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @certificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Certifications/Degrees'**
  String get certificationsLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @permissionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsLabel;

  /// No description provided for @permissionsDetails.
  ///
  /// In en, this message translates to:
  /// **'Permission details'**
  String get permissionsDetails;

  /// No description provided for @connectionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Server connection successful'**
  String get connectionSuccess;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to server'**
  String get connectionFailed;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Error checking connection'**
  String get connectionError;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @connexionOk.
  ///
  /// In en, this message translates to:
  /// **'Your internet connection is OK'**
  String get connexionOk;

  /// No description provided for @authLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed, please check your credentials'**
  String get authLoginFailed;

  /// No description provided for @modele.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modele;

  /// No description provided for @property.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get property;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout!'**
  String get logout;
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
    'that was used.',
  );
}
