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
      'Si vous n\'avez pas de compte, veuillez vous rapprocher de votre Administrateur.';

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
  String get errorsInvalidEmail => 'Veuillez entrer un email valide';

  @override
  String get authEmail => 'Adresse email';

  @override
  String get authPhone => 'Téléphone';

  @override
  String get emailRequired => 'L\'email est requis';

  @override
  String get phoneRequired => 'Le numéro de téléphone est requis';

  @override
  String get invalidPhone => 'Numéro de téléphone invalide';

  @override
  String get passwordRequired => 'Le mot de passe est requis';

  @override
  String get phoneFormatCM => 'Format: 9 chiffres (ex: 698765432)';

  @override
  String get phoneFormatGA => 'Format: 8 chiffres (ex: 06012345)';

  @override
  String get phoneFormatTD => 'Format: 8 chiffres (ex: 63012345)';

  @override
  String get phoneFormatCF => 'Format: 8 chiffres (ex: 70012345)';

  @override
  String get phoneFormatNG => 'Format: 10 chiffres (ex: 8012345678)';

  @override
  String get phoneFormatGQ => 'Format: 9 chiffres (ex: 222123456)';

  @override
  String get phoneFormatCO => 'Format: 10 chiffres (ex: 6012345678)';

  @override
  String get phoneFormatDefault => 'Entrez un numéro de téléphone valide';

  @override
  String get selectCountry => 'Sélectionner un pays';

  @override
  String get searchCountry => 'Rechercher un pays';

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
  String get waitingDiagnotics => 'En attente de diagnostic';

  @override
  String get waitingValidationDiagnostic => 'En attente validation diagnostic';

  @override
  String get waitingValidation => 'En attente validation\nintervention';

  @override
  String get repairing => 'Réparation en cours';

  @override
  String get finished => 'Terminé';

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

  @override
  String get technicianRole => 'Technicien';

  @override
  String get add => 'Ajouter';

  @override
  String get immatVehicule => 'Imm';

  @override
  String get validation => 'En validation';

  @override
  String get userProfile => 'Profil utilisateur';

  @override
  String get administratorRole => 'Administrateur';

  @override
  String get updateProfile => 'Mettre à jour';

  @override
  String get nameLabel => 'Nom';

  @override
  String get biographyLabel => 'Biographie';

  @override
  String get certifiedTechnician => 'Technicien certifié';

  @override
  String get phoneNumberLabel => 'Numéro de téléphone';

  @override
  String get certificationsLabel => 'Certifications et/ou diplômes';

  @override
  String get roleLabel => 'Rôle';

  @override
  String get permissionsLabel => 'Permissions';

  @override
  String get permissionsDetails => 'Détails des permissions';

  @override
  String get connectionSuccess => 'Connexion au serveur réussie';

  @override
  String get connectionFailed => 'Échec de connexion au serveur';

  @override
  String get connectionError =>
      'Erreur lors de la vérification de la connexion';

  @override
  String get noInternetConnection => 'Pas de connexion Internet';

  @override
  String get connexionOk => 'Connexion internet OK';

  @override
  String get authLoginFailed =>
      'Échec de la connexion, veuillez vérifier vos identifiants';

  @override
  String get modele => 'Chassis';

  @override
  String get property => 'Propriétaire';

  @override
  String get logout => 'Déconnexion!';

  @override
  String get adminRole => 'Administrateur';

  @override
  String get users => 'Utilisateurs';

  @override
  String get lastLogin => 'Dernière connexion';

  @override
  String get resetPasswordSent =>
      'Demande envoyée. Vérifiez votre administrateur pour le code.';

  @override
  String get resetPasswordError => 'Erreur lors de l\'envoi de la demande';

  @override
  String get resetPasswordEmailPrompt =>
      'Entrez votre email pour réinitialiser le mot de passe';

  @override
  String get resetPasswordPhonePrompt =>
      'Entrez votre numéro et celui de votre administrateur';

  @override
  String get eitherEmailOrPhonesRequired =>
      'Email ou numéros de téléphone manquants';

  @override
  String get verificationCodeTitle => 'Code de vérification';

  @override
  String get verificationCodeSentEmail =>
      'Un code a été envoyé à votre administrateur. Entrez-le ici:';

  @override
  String get verificationCodeSentAdminPhone =>
      'Un code a été envoyé à votre administrateur. Entrez-le ici:';

  @override
  String get verificationCodeInvalid => 'Le code doit contenir 6 caractères';

  @override
  String get verificationCodeFailed => 'Code invalide. Veuillez réessayer';

  @override
  String get verificationCodeSuccess => 'Code vérifié avec succès!';

  @override
  String get verify => 'Vérifier';

  @override
  String get userPhoneNumber => 'Votre numéro';

  @override
  String get adminPhoneNumber => 'Numéro administrateur';

  @override
  String get adminPhoneHint => 'Numéro de votre admin';

  @override
  String get bothPhonesRequired => 'Les deux numéros sont requis';

  @override
  String get submit => 'Envoyer';

  @override
  String get cancel => 'Annuler';

  @override
  String get userPhoneInvalid => 'Numéro utilisateur invalide';

  @override
  String get adminPhoneInvalid => 'Numéro administrateur invalide';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get resetPasswordSucces => 'Mot de passe réinitialisé';
}
