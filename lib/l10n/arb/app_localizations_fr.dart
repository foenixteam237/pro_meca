// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ProMéca';

  @override
  String get appWelcome => 'Bienvenue !';

  @override
  String get appStart => 'Commencer !';

  @override
  String get authLogin => 'Connexion';

  @override
  String get authPhoneNumber => 'Numéro de téléphone';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authRememberMe => 'Se souvenir de moi';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authLoginMessage =>
      'Si vous n\'avez pas de compte, veuillez vous rapprocher de votre chef.';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonBack => 'Retour';

  @override
  String get errorsRequiredField => 'Ce champ est obligatoire';

  @override
  String get errorsInvalidEmail => 'Email invalide';

  @override
  String get completedVehicles => 'Véhicule terminé';

  @override
  String get ongoingVehicles => 'Véhicule en cours';

  @override
  String get repair => 'Réparation';

  @override
  String get clientValidation => 'Validation client';

  @override
  String get diagnostic => 'Diagnostique';

  @override
  String get seeInvoice => 'Voir la facture';

  @override
  String get vehicleRegistrationHint => 'Immatriculation du véhicule';

  @override
  String get viewMore => 'Voir plus';

  @override
  String get home => 'Accueil';

  @override
  String get parts => 'Pièces';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get profile => 'Profil';
}
