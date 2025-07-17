// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ProMéca';

  @override
  String get appWelcome => 'Welcome!';

  @override
  String get appStart => 'Start!';

  @override
  String get authLogin => 'Login';

  @override
  String get authPhoneNumber => 'Phone number';

  @override
  String get authPassword => 'Password';

  @override
  String get authRememberMe => 'Remember me';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authLoginMessage =>
      'If you don\'t have an account, please contact your manager.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get errorsRequiredField => 'This field is required';

  @override
  String get errorsInvalidEmail => 'Invalid email';
}
